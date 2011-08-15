<?php

$login_file = "hs_login.php";
// Set this value to the path and filename of the hs_login.php file.
// This file includes the login username and password for your MySQL user account,
// the MySQL hostname and database name, as well as the password you'd like to
// use to protect the high score manager.
// *** IMPORTANT *** For security reasons, it is a very good idea to place the
// above file in a non-web-visible directory, such as the directory above your HTML
// root directory.


function getvar($var, $type){
	global $HTTP_SERVER_VARS;
	global $HTTP_POST_VARS;
	global $HTTP_GET_VARS;
	eval("global \$". $var .";");
	switch($type){
		
		case "server":
		if (isset($_SERVER[$var]))			eval("\$". $var ." = '". $_SERVER[$var] ."';");
		else if (isset($HTTP_SERVER_VARS[$var]))	eval("\$". $var ." = '". $HTTP_SERVER_VARS[$var] ."';");
		break;
			
		case "post":
		if (isset($_POST[$var]))			eval("\$". $var ." = '". $_POST[$var] ."';");
		else if (isset($HTTP_POST_VARS[$var]))		eval("\$". $var ." = '". $HTTP_POST_VARS[$var] ."';");
		break;
			
		case "get":
		if (isset($_GET[$var]))				eval("\$". $var ." = '". $_GET[$var] ."';");
		else if (isset($HTTP_GET_VARS[$var]))		eval("\$". $var ." = '". $HTTP_GET_VARS[$var] ."';");
		break;
			
	}
}

function email_scores($id){
	global $db;
	$games = mysql_query("SELECT * FROM hs_games WHERE id=".$id, $db);
	$game = mysql_fetch_array($games);
	
	$email = "Cleared Scores for \"".$game['name']."\" (GAME ID: ".$game['id'].")\n\n";
	$scores = mysql_query("SELECT * FROM hs_scores WHERE gameid=". $id ." ORDER BY score DESC", $db);
	$str_lengths = array("count"=>0, "player"=>0, "score"=>0, "email"=>0);
	$vals_count = array();
	$vals_player = array();
	$vals_score = array();
	$vals_date = array();
	$vals_email = array();
	$count = 1;
	while ($score = mysql_fetch_array($scores)){
		if (strlen($count) > $str_lengths['count']) $str_lengths['count'] = strlen($count);
		if (strlen($score['player']) > $str_lengths['player']) $str_lengths['player'] = strlen($score['player']);
		if (strlen($score['score']) > $str_lengths['score']) $str_lengths['score'] = strlen($score['score']);
		if (strlen($score['email']) > $str_lengths['email']) $str_lengths['email'] = strlen($score['email']);
		$vals_count[] = $count;
		$vals_player[] = urldecode(censor_word($score['player']));
		$vals_score[] = $score['score'];
		list($y,$m,$d) = split("-", $score['date']);
		$vals_date[] = str_pad($m,2,"0",STR_PAD_LEFT)."/".str_pad($d,2,"0",STR_PAD_LEFT)."/".str_pad($y,4,"0",STR_PAD_LEFT);
		$vals_email[] = $score['email'];
		$count++;
	}
	for($n=0; $n<count($vals_count); $n++){
		$email .= str_pad($vals_count[$n], $str_lengths['count'], " ", STR_PAD_LEFT).".  ";
		$email .= str_pad($vals_player[$n], $str_lengths['player'])."   ";
		$email .= str_pad($vals_score[$n], $str_lengths['score'])."   ";
		$email .= $vals_date[$n]."   ";	// date is of constant length MM/DD/YYYY
		$email .= str_pad($vals_email[$n], $str_lengths['email'])."\n";
	}
	$email .= "\n\nGame Settings:";
	$email .= "\nMax Scores = ".$game['maxscores'];
	$email .= "\nClear Interval = ".ucfirst($game['clearinterval']);
	$email .= "\nAsk for Player Email = ".ucfirst($game['recordplayeremail']);
	$email .= "\nMax Characters in Player Name = ".$game['maxchars'];
	$email .= "\nShow Score Dates = ". $game['showdate'];
	$email .= "\nPlayer Email Request Message = ". urldecode($game['emailpromptmessage']);
	
	$email .= "\n\n";
	$email .= "This email is easiest to read in a fixed-width font.\n\n";
	$clear_ok = true;
	if ($game['emailscores'] == "yes"){
		$settings = mysql_query("SELECT * FROM hs_settings WHERE id=1",$db);
		if ($setting = mysql_fetch_array($settings)){	// email scores
			if (!mail(urldecode($setting['email']), "CLEARED SCORES for \"". $game['name'] ."\"", $email)){
				$clear_ok = false;	// mail not sent, do not clear scores!
			}
		}else{
			$clear_ok = false;	// settings table not found, can't email, don't clear scores!
		}
	}
	return $clear_ok;
}

function clear_scores($gameid){
	global $db;
	mysql_query("DELETE FROM hs_scores WHERE gameid=". $gameid, $db);
	mysql_query("UPDATE hs_games SET lastcleared=\"". date("Y")."-".date("m")."-".date("d") ."\" WHERE id=". $gameid, $db);
}

function censor_word($word){
	global $db;
	$replace_char = "*";
	
	$result = mysql_query("SELECT * FROM hs_settings WHERE id=1", $db);
	$row = mysql_fetch_array($result);
	
	$words = split(",", urldecode($row['words_ready']));
	for ($w=0; $w<count($words); $w++){
		$currw = trim($words[$w]);
		if (strlen($currw) <= 0) continue;	// skip blank test words
		$chars = array();	
		$replace_word = "";
		for ($n=0; $n<strlen($currw); $n++){	// split word into array of chars
			
			$char = substr($currw, $n, 1);
			if (ereg("i", strtolower($char))){		// if word contains an i, replace with a check for i, 1, ! or | in the same position:
				$chars[] = "[i1!\|]";	
			}else if (ereg("s", strtolower($char))){	// if word contains an s, replace with a check for 5 as well:
				$chars[] = "[s5]";
			}else if (ereg("e", strtolower($char))){	// if word contains an e, replace with a check for 3 as well:
				$chars[] = "[e3]";
			}else if (ereg("t", strtolower($char))){	// if word contains an t, replace with a check for 7 or + as well:
				$chars[] = "[t7\+]";
			}else if (ereg("o", strtolower($char))){	// if word contains an o, replace with a check for 0 as well:
				$chars[] = "[o0]";
			}else if (ereg("a", strtolower($char))){	// if word contains an a, replace with a check for 4 as well:
				$chars[] = "[a4]";
			}else if (ereg("b", strtolower($char))){	// if word contains an b, replace with a check for |3 as well:
				$chars[] = "(b|\|3)";
			}else{
				$chars[] = $char;
			}	
			$replace_word .= $replace_char;
		}
		for ($n=0; $n<count($chars); $n++){
			$chars[$n] = str_replace("*", "\\*", $chars[$n]);	
		}
		$match = join("+[^a-zA-Z0-9]*", $chars);
		$word = eregi_replace ($match, $replace_word, $word);
	}			
	return $word;		
}



?>
