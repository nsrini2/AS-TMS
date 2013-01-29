<?php

include "hs_global.php";
include $login_file;

// global vars
getvar("action", "get");

// score submit vars
getvar("id", "get");
getvar("player", "get");
getvar("score", "get");
getvar("email", "get");
getvar("rand", "get");	// md5 key part
getvar("rand2", "get");	// md5 hash

// challenge vars
getvar("friend", "get");
getvar("yourname", "get");


$db = mysql_connect($sql_hostname, $sql_username, $sql_password);
mysql_select_db($sql_database, $db);

function check_email($email){
	if (!ereg( "^([0-9,a-z,A-Z]+)([.,_]([0-9,a-z,A-Z]+))*[@]([0-9,a-z,A-Z]+)([.,_,-]([0-9,a-z,A-Z]+))*[.]([0-9,a-z,A-Z]){2}([0-9,a-z,A-Z])*$", $email)) {	// invalid email format
		return false;
	}else{
		return true;
	}
}
function isexpired($lastcleared, $clearinterval){
	$days_to_add = 0;
	switch ($clearinterval){
		case "daily": $days_to_add = 1; break;	
		case "weekly": $days_to_add = 7; break;	
		case "monthly": $days_to_add = 30; break;	
		case "quarterly": $days_to_add = 90; break;	
		case "annually": $days_to_add = 365; break;
		default: return false; break;	// never	
	}
	list($starty, $startm, $startd) = split("-", $lastcleared);
	$exp_date = mktime(0,0,0, $startm, $startd, $starty);
	$now_date = mktime();
	if (($now_date - $exp_date) >= ($days_to_add*60*60*24)){
		return true;	
	}else{
		return false;
	}	
}

function isroom(){
	global $db, $id;
	$games = mysql_query("SELECT * FROM hs_games WHERE id=". $id, $db);
	$game = mysql_fetch_array($games);
	$scores = mysql_query("SELECT * FROM hs_scores WHERE gameid=". $id ." ORDER BY score", $db);
	$numscores = mysql_num_rows($scores);
	$maxscores = $game['maxscores'];
	if ($numscores < $maxscores){	// still room left in scores list, add score
		return true;	
	}else{
		return false;
	}
}
function get_replace_id(){
	global $db, $id, $score, $debug;
	$minscores = mysql_query("SELECT * FROM hs_scores WHERE gameid=". $id ." ORDER BY score, date", $db);
	$minscore = mysql_fetch_array($minscores);
	if ($score <= $minscore['score']){	// score is not high enough to be posted
		$debug = "score too low";
		return -1;
	}else{
		return $minscore['id'];
	}
}
function get_encoded_scores(){
	global $db, $id, $latest;
	$games = mysql_query("SELECT * FROM hs_games WHERE id=". $id, $db);
	$game = mysql_fetch_array($games);
	$scores = mysql_query("SELECT * FROM hs_scores WHERE gameid=". $id ." ORDER BY score DESC", $db);
	$out = "&numscores=".mysql_num_rows($scores);
	$out .= "&maxscores=".$game['maxscores'];
	$out .= "&showdate=".$game['showdate'];
	$out .= "&emailtofriend=".$game['emailtofriend'];
	list($y,$m,$d) = split("-", $game['lastcleared']);
	$out .= "&cleardate=". urlencode($m."/".$d."/".substr($y,2));
	$curr_score_num = -1;
	$count = 0;
	while ($score = mysql_fetch_array($scores)){
		//list($d, $t) = split(" ", $score['date']);
		list($y, $m, $day) = split("-", $score['date']);
		$y = substr($y, 2);
		$m = round($m);
		$day = round($day);
		$out .= "&p". $count ."=". urlencode(censor_word($score['player'])) ."&s". $count ."=". $score['score'] ."&d". $count ."=". $m .urlencode("/"). $day .urlencode("/"). $y;
		if (isset($latest) && ($score['id'] == $latest['id'])){
			$curr_score_num = $count;	
		}
		$count++;
	}
	$out .= "&current=".$curr_score_num;
	$out .= "&";	
	return $out;
}
function get_from_header(){
	global $db;
	$from_head = "From: ";
	$settings = mysql_query("SELECT * FROM hs_settings WHERE id=1", $db);
	if ($setting = mysql_fetch_array($settings)){
		if (isset($setting['challenge_name']) && strlen($setting['challenge_name'])>1){
			$from_head .= str_replace("\\\"",'"',urldecode($setting['challenge_name']));
		}else{
			$from_head .= 'High Score System';
		}
		if (isset($setting['challenge_email']) && strlen($setting['challenge_email'])>1){
			$challenge_email = urldecode($setting['challenge_email']);
			if (check_email($challenge_email)){
				$from_head .= " <".$challenge_email.">\r\n";
			}else{
				return false;
			}
			return $from_head;
		}else{
			return false;
		}
	}
	return false;
}

if (!isset($id)) exit();

//---\/--- CHECK FOR CLEAR ---
$games = mysql_query("SELECT * FROM hs_games WHERE id=".$id, $db);
if ($game = mysql_fetch_array($games)){
	if (isexpired($game['lastcleared'], $game['clearinterval'])){
		if (email_scores($id)){
			clear_scores($id);	
		}
	}	
}
//---/\--- CHECK FOR CLEAR ---


if (strtolower($action) == "check"){
	
	//=====\/===== CHECK =====
	$games = mysql_query("SELECT * FROM hs_games WHERE id=".$id, $db);
	$game = mysql_fetch_array($games);
	
	$default_result = "&result=yes&lowscore=-1&maxchars=".$game['maxchars']."&recordplayeremail=".$game['recordplayeremail']."&harvest_all_emails=". (isset($game['harvest_all_emails']) ? $game['harvest_all_emails'] : "no") ."&emailpromptmessage=".$game['emailpromptmessage']."&";
	if (isroom()){
		echo $default_result;
		exit;	
	}else if (get_replace_id() != -1){
		echo $default_result;
		exit;	
	}else{
		$lowest_score = 0;
		$lowscores = mysql_query("SELECT * FROM hs_scores WHERE gameid=". $id ." ORDER BY score", $db);
		if ($lowscore = mysql_fetch_array($lowscores)){
			$lowest_score = $lowscore['score'];	
		}	
		echo "&result=no&lowscore=".$lowest_score."&maxchars=".$game['maxchars']."&harvest_all_emails=". (isset($game['harvest_all_emails']) ? $game['harvest_all_emails'] : "no") ."&lowscoremessage=". ((isset($game['lowscoremessage']) && $game['lowscoremessage']!="") ? $game['lowscoremessage'] : "Score+over+%25+points+to+earn+a+spot+on+the+high+score+table%21") ."&";
		exit;	
	}
	//=====/\===== CHECK =====
	
}else if (strtolower($action) == "get"){

	//=====\/===== GET =====
	echo get_encoded_scores();
	exit;
	//=====/\===== GET =====
	
}else if (strtolower($action) == "getid"){

	//=====\/===== GETID =====
	if (isroom()){
		echo "&id=NEW&";
		exit;
	}else{
		$rep_id = get_replace_id();
		echo "&id=".get_replace_id(). (isset($debug) ? "&debug=".$debug : "") ."&";
		exit;
	}
	//=====/\===== GETID =====
	
}else if (strtolower($action) == "set"){
	
	//=====\/===== SET =====
	
	if (md5($id."-".$score."-".$rand."...you shall not pass") == $rand2){
		$date = date("Y")."-".date("m")."-".date("d");//." ".date("H").":".date("i").":".date("s");
		if (isroom()){
			mysql_query("INSERT INTO hs_scores (gameid, player, score, date, email) VALUES (".$id.", '". urlencode($player) ."', ".$score.", '".$date."', '". urlencode($email) ."')", $db) or die(mysql_error());
		}else{
			$rep_id = get_replace_id();
			if ($rep_id != -1){
				mysql_query("UPDATE hs_scores SET gameid=".$id.", player='". urlencode($player) ."', score=".$score.", date='".$date."', email='". urlencode($email) ."' WHERE id=".$rep_id, $db);
			}
		}
		//--\/-- UPDATE HS_EMAILS TABLE --
		$email = trim($email);
		if (($game['recordplayeremail']=='yes' || $game['harvest_all_emails']=='yes') && (check_email($email))){
			$email_rows = mysql_query("SELECT * FROM hs_emails WHERE LOWER(email)='".strtolower(urlencode($email))."'", $db);
			if ($email_row = mysql_fetch_array($email_rows)){	// update count
				mysql_query("UPDATE hs_emails SET gameid=".$id.", count=".($email_row['count']+1).", date='".$date."' WHERE id=".$email_row['id'], $db);
				if ($email_row['player'] == "" && $player != ""){	// set new player name
					mysql_query("UPDATE hs_emails SET player='".urlencode($player)."' WHERE id=".$email_row['id'], $db);
				}
			}else{
				mysql_query("INSERT INTO hs_emails (gameid, player, date, email) VALUES (".$id.", '". urlencode($player) ."', '".$date."', '". urlencode($email) ."')", $db);
			}
		}
		//--/\-- UPDATE HS_EMAILS TABLE --
		$latests = mysql_query("SELECT * FROM hs_scores WHERE gameid=".$id." AND score=".$score." AND player='". urlencode($player) ."' ORDER BY date DESC", $db);
		$latest = mysql_fetch_array($latests);
	}
	echo get_encoded_scores();
	exit;
	//=====/\===== SET =====

}else if (strtolower($action) == "challenge"){

	//=====\/===== CHALLENGE =====
	$games = mysql_query("SELECT * FROM hs_games WHERE id=".$id, $db);
	$game = mysql_fetch_array($games);	
	
	$yourname = urldecode($yourname);
	$friend = trim(urldecode($friend));
	$friend = str_replace(" ", ",", $friend);
	if (strlen($yourname)<=0 || $yourname=="") $yourname = "Anonymous";
	$title = "\"".$yourname."\" Has Challenged You To Beat A High Score!";
	$body = 'Your friend "'. $yourname .'" just finished playing "'. urldecode($game['name']) .'" and wanted to brag to you about a score of '.$score.' points!';
	$body .= "\nYou're not going to take this lying down, are you? Get in there and beat that score! Go to the URL below to start playing!\n\n------------------------------\n\n";
	$body .= "Game: ".urldecode($game['name'])."\n";
	$body .= "Score: ".$score." by \"".$yourname."\"\n";
	$body .= "PLAY NOW: ".urldecode($game['gameurl'])."\n\n";
	$body .= "------------------------------\n";
	$body .= "Please do not reply to this email.\n";
	
	
	$notify = false;
	$from_head = get_from_header();
	$friends = split(",", $friend);
	for ($n=0; $n<count($friends); $n++){
		if (check_email($friends[$n])){
			$notify = true;
			if ($from_head !== false){
				mail($friends[$n], $title, $body, $from_head);
			}else{
				mail($friends[$n], $title, $body);
			}
		}
	}
	if ($notify){
		//mail("scottb@eyeland.com,jshamlin@austin.rr.com", "GIAF: Challenge (".urldecode($game['name']).") ".$yourname." TO ".$friend, $body);	
	}
	echo "&result=yes&";
	exit;
	//=====/\===== CHALLENGE =====
	
}

?>