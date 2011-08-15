<?php

include "hs_global.php";
include $login_file;

$logged_in = false;
$def_emailpromptmessage = urlencode("You got a high score! Submit your score below.");
$def_lowscoremessage = urlencode("Score over % points to earn a spot on the high score table!");

// global vars
getvar("PHP_SELF", "server");
getvar("password", "post");

// game settings vars
getvar("gameid", "post");
getvar("scoreid", "post");
getvar("name", "post");
getvar("maxscores", "post");
getvar("clearinterval", "post");
getvar("emailscores", "post");
getvar("recordplayeremail", "post");
getvar("harvest_all_emails", "post");
getvar("emailpromptmessage", "post");
getvar("lowscoremessage", "post");
getvar("maxchars", "post");
getvar("player_fields", "post");
getvar("showdate", "post");
getvar("emailtofriend", "post"); // Carvel added
getvar("gameurl", "post"); // Carvel added
getvar("gid", "get"); //Carvel added

// global settings vars
getvar("email", "post");
getvar("challenge_name", "post");
getvar("challenge_email", "post");
getvar("words", "post");

// menu vars
getvar("badwords_submit", "post");
getvar("badwords_edit", "post");
getvar("game_add", "post");
getvar("game_view", "post");
getvar("game_del", "post");
getvar("game_edit", "post");
getvar("game_apply", "post");
getvar("settings_edit", "post");
getvar("settings_apply", "post");
getvar("score_delete", "post");
getvar("view_clear", "post");
getvar("refresh", "post");
getvar("view_clear_confirm", "post");
getvar("view_clear_confirm_email", "post");
getvar("del_confirm", "post");
getvar("db_setup", "post");

function check_email($email){
	if (!ereg( "^([0-9,a-z,A-Z]+)([.,_]([0-9,a-z,A-Z]+))*[@]([0-9,a-z,A-Z]+)([.,_,-]([0-9,a-z,A-Z]+))*[.]([0-9,a-z,A-Z]){2}([0-9,a-z,A-Z])*$", $email)) {	// invalid email format
		return false;
	}else{
		return true;
	}
}
function longest_strlen($words){
	for ($n=0; $n<count($words); $n++){
		if (!isset($longest)){
			$longest = strlen($words[$n]);
		}else if (strlen($words[$n]) > $longest){
			$longest = strlen($words[$n]);
		}
	}
	return $longest;
}
function sortstrlen($words){
	$out_words = array();
	$curr_len = longest_strlen($words);
	while (count($out_words) != count($words)){
		$curr_words_to_move = array();
		for ($n=0; $n<count($words); $n++){
			if (strlen($words[$n]) == $curr_len){
				$curr_words_to_move[] = $n;
			}			
		}
		for ($n=0; $n<count($curr_words_to_move); $n++){
			$out_words[] = $words[$curr_words_to_move[$n]];
		}
		$curr_len--;	
	}
	return $out_words;
}
function mysql_table_exists($table_name){
	global $db, $sql_database;
	$tables = array();
	$tables_result = mysql_list_tables($sql_database, $db);
	while ($row = mysql_fetch_row($tables_result)) $tables[] = $row[0];
	return(in_array(strtolower($table_name), $tables));
}
function escape_field($str){
	$str = str_replace("\\\"","&quot;",$str);	
	$str = str_replace("\"","&quot;",$str);
	return ($str);
}

$sql_setup_cmd = "DROP TABLE IF EXISTS hs_games;
CREATE TABLE hs_games (
  id int(11) NOT NULL auto_increment,
  name varchar(80) NOT NULL default '',
  maxscores bigint(20) NOT NULL default '25',
  lastcleared date NOT NULL default '0000-00-00',
  clearinterval enum('daily','weekly','monthly','quarterly','annually','never') NOT NULL default 'never',
  emailscores enum('yes','no') NOT NULL default 'yes',
  recordplayeremail enum('yes','no') NOT NULL default 'no',
  harvest_all_emails enum('yes','no') NOT NULL default 'no',
  emailpromptmessage text NOT NULL,
  lowscoremessage text NOT NULL,
  maxchars enum('0','3','5','8','10','20') NOT NULL default '20',
  showdate enum('yes','no') NOT NULL default 'no',
  emailtofriend enum('yes','no') NOT NULL default 'no',
  gameurl varchar(100) NOT NULL default '',
  PRIMARY KEY  (id)
) TYPE=MyISAM;
DROP TABLE IF EXISTS hs_emails;
CREATE TABLE hs_emails (
  id int(11) NOT NULL auto_increment,
  gameid int(11) NOT NULL default '0',
  player varchar(80) NOT NULL default '',
  date date NOT NULL default '0000-00-00',
  email varchar(100) NOT NULL default '',
  count int(11) NOT NULL default '1',
  PRIMARY KEY (id)
) TYPE=MYISAM;
DROP TABLE IF EXISTS hs_scores;
CREATE TABLE hs_scores (
  id int(11) NOT NULL auto_increment,
  gameid int(11) NOT NULL default '0',
  player varchar(80) NOT NULL default '',
  score bigint(20) NOT NULL default '0',
  date date NOT NULL default '0000-00-00',
  email varchar(100) NOT NULL default '',
  PRIMARY KEY  (id)
) TYPE=MyISAM;
DROP TABLE IF EXISTS hs_settings;
CREATE TABLE hs_settings (
  id int(11) NOT NULL default '0',
  words text NOT NULL,
  words_ready text NOT NULL,
  email varchar(80) NOT NULL default '',
  challenge_name varchar(80) NOT NULL default '',
  challenge_email varchar(80) NOT NULL default '',
  PRIMARY KEY  (id)
) TYPE=MyISAM;
INSERT INTO hs_settings (id,words,words_ready,email,challenge_name,challenge_email) VALUES (1, 'fuc%0D%0Afuk%0D%0Afuq%0D%0Asht%0D%0Acum%0D%0Ashit%0D%0Afuck%0D%0Adamn%0D%0Abitch%0D%0Apussy%0D%0Ahell%0D%0Acunt%0D%0Acock%0D%0Adick%0D%0Anigger%0D%0Anigga%0D%0Apenis%0D%0Abastard%0D%0Aass%0D%0Aporn%0D%0Apron', 'bastard%2Cnigger%2Cbitch%2Cpussy%2Cnigga%2Cpenis%2Cshit%2Cfuck%2Cdamn%2Chell%2Ccunt%2Ccock%2Cdick%2Cporn%2Cpron%2Cfuc%2Cfuk%2Cfuq%2Csht%2Ccum%2Cass', '', '', '');";


?>


<html>
<head>
<style type="text/css">
<!--

BODY{
	color: black;
	font-size: 10pt;
	font-family: Verdana, Arial, sans-serif;
}
TD{
	color: black;
	font-size: 9pt;
	font-family: Verdana, Arial, sans-serif;
}
.large{
	color: black;
	font-size: 13pt;
	font-family: Verdana, Arial, sans-serif;
}
.small{
	color: black;
	font-size: 7pt;
	font-family: Verdana, Arial, sans-serif;
}
.bold{
	font-weight : bold;
}

//-->
</style>
</head>
<title>Games In A Flash: High Score Manager</title>
<body leftmargin=0 rightmargin=0 topmargin=0 bottommargin=0 marginwidth=0 marginheight=0 bgcolor="#516D7D">

<table width="100%" bgcolor="#8ED1BE"><tr><td><b><a href="http://www.gamesinaflash.com/" target="_new">Games In A Flash</a><br><span class="large">&nbsp;High Score Manager</span></b></td></tr></table>
<table width="100%" bgcolor="#7097AD" cellpadding=30><tr><td align="center">
<!--/\-- header -->

<?php

$err_connect = 'There was an error connecting to the MySQL database. Most likely, the hostname, username, and/or password listed in the "hs_login.php" file do not match your server\'s configuration. Please check these values and try again. If you are unsure about what these values should be, contact your web host for help.';
$err_database = 'A connection was successfully made to your MySQL server, but the specified database could not be selected. Please double-check the database value in the "hs_login.php" file and try again. If you are unsure about what your database\'s name is, or how to create a new database, contact your web host for help.';

if ($hs_password == "" || (isset($password) && $password == $hs_password)){
	if (($db = @mysql_connect($sql_hostname, $sql_username, $sql_password)) != true){
		$error = $err_connect;
	}else{	// no error connecting, try selecting db:
		if (!@mysql_select_db($sql_database, $db)) $error = $err_database;
	}
	if (!isset($error)) $logged_in = true;
}


if ($logged_in){
	if (isset($badwords_test) && isset($words)){
		$badwords_submit = 1;	
	}
	
	if (isset($badwords_submit)){	// prep words for faster use by censor function in hs_scores.php:
		$words_ready = str_replace(" ", ",", $words);
		$words_ready = str_replace("\r\n", ",", $words_ready);
		$words_ready = str_replace("\r", ",", $words_ready);
		$words_ready = str_replace("\n", ",", $words_ready);
		$words_ready = split(",", $words_ready);
		for ($n=0; $n<count($words_ready); $n++){
			if (strlen(trim($words_ready[$n])) <= 0) $words_ready = array_splice($words_ready, $n, 1);	
		}
		$words_ready = sortstrlen($words_ready);
		$words_ready = join(",", $words_ready);
		
		mysql_query("UPDATE hs_settings SET words_ready='".urlencode($words_ready)."' WHERE id=1", $db);
		mysql_query("UPDATE hs_settings SET words='".urlencode($words)."' WHERE id=1", $db);
		
		if (!isset($badwords_test)) $settings_edit = 1;
	}
	if (isset($score_delete)){
		mysql_query("DELETE FROM hs_scores WHERE id=".$scoreid, $db);
		unset($score_delete);
		$game_view = 1;	
	}
	if (isset($db_setup)){
		$sql = str_replace("\r\n", "", $sql_setup_cmd);
		$sql = str_replace("\r", "", $sql);
		$sql = str_replace("\n", "", $sql);
		$sqls = split(";", $sql);
		for ($n=0; $n<count($sqls); $n++){
			if (strlen(trim($sqls[$n]))>0){
				mysql_query(trim($sqls[$n]).";",$db);
			}
		}
	}	
	
	// check for existance of tables:
	if (!mysql_table_exists("hs_games") || !mysql_table_exists("hs_scores") || !mysql_table_exists("hs_settings")){
		echo '<table bgcolor="#8ED1BE" width=500>';
		echo '<tr><td bgcolor="#509C86" class="large"><b>Database Setup</b></td></tr>';
		echo '<form method="post" action="'.$PHP_SELF.'">';
		echo '<input type="hidden" name="password" value="'.$password.'">';
		echo '<tr><td>';
		echo 'The High Score Manager needs to create tables in your database to keep track of games, scores, and settings.<p>';
		echo 'Press Continue to create tables named <b>hs_games</b>, <b>hs_scores</b>, <b>hs_emails</b>, and <b>hs_settings</b> in database <b>'.$sql_database.'</b>.';
		echo '</td></tr>';
		echo '<tr><td align="right"><input type="submit" value="Continue" name="db_setup"></td></tr>';
		echo '</form></table>';
		$logged_in = false;
	}
	
}else{

	if (isset($error)){

		echo '<table bgcolor="#8ED1BE" width=500>';
		echo '<form method="post" action="'.$PHP_SELF.'">';
		echo '<input type="hidden" name="password" value="'.$password.'">';
		echo '<tr><td><span class="large"><b>Error:</b></span> ';
		echo $error;
		echo '</td></tr>';
		echo '<tr><td align="right"><input type="submit" value="Try Again" name="refresh"></td></tr>';
		echo '</form></table>';

	}else{	// no db errors, but not logged in, so ask for password again
		echo '<table bgcolor="#8ED1BE">';
		echo '<tr><td bgcolor="#509C86" class="large"><b>Login</b></td></tr>';
		echo '<form method="post" action="'.$PHP_SELF.'">';
		echo '<tr><td>Password: <input type="password" size=20 name="password"></td></tr>';
		echo '<tr><td align="right"><input type="submit" value="Enter" name="login_submit"></td></tr>';
		echo '</form></table>';
	}
}
if ($logged_in){
	if (isset($game_view)){
		
		$scores = mysql_query("SELECT * FROM hs_scores WHERE gameid=". $gameid ." ORDER BY score DESC, date", $db);
		$games = mysql_query("SELECT * FROM hs_games WHERE id=". $gameid, $db);
		$game = mysql_fetch_array($games);
		echo '<table id="high_scores" bgcolor="#8ED1BE" cellpadding=6><tr><td bgcolor="#509C86" class="large" colspan=5><b>High Scores for "'. urldecode($game['name']) .'"</b></td></tr>';
		echo '<tr><td><b>Player</b></td><td><b>Score</b></td><td><b>Email</b></td><td><b>Date</b><br>(YYYY-MM-DD)</td><td></td></tr>';
		while ($score = mysql_fetch_array($scores)){
			echo '<tr><td><b>'. urldecode($score['player']) .'</b>';
			if (urldecode($score['player']) != censor_word(urldecode($score['player']))){
				echo '<br>&nbsp;(Censored as: '. censor_word(urldecode($score['player'])) .')';
			}
			echo '</td>';
			echo '<td>'. $score['score'] .'</td>';
			echo '<td>'. urldecode($score['email']) .'</td>';
			echo '<td>'. $score['date'] .'</td>';
			echo '<form method="post" action="'.$PHP_SELF .'"><input type="hidden" name="password" value="'. $password .'"><input type="hidden" name="scoreid" value="'. $score['id'] .'"><input type="hidden" name="gameid" value="'. $game['id'] .'"><td><input type="submit" name="score_delete" value="Delete"></td></form>';
			echo '</tr>';
		}
		echo '<form method="post" action="'.$PHP_SELF .'">';
		echo '<input type="hidden" name="password" value="'. $password .'">';
		echo '<input type="hidden" name="gameid" value="'. $game['id'] .'">';
		echo '<tr><td colspan=3 align="right"><input type="submit" name="game_view" value="Reload Scores"> <input type="submit" name="view_clear" value="Clear All Scores"> <input type="submit" name="refresh" value="Return to Main"></td></tr>';
		echo '</form></table>';
		
	}else if (isset($emails_view)){
		
		echo '<table bgcolor="#8ED1BE" cellpadding=6><tr><td bgcolor="#509C86" colspan=5><span class="large"><b>Harvested Emails</b></span></td></tr>';
		echo '<form method="post" action="'.$PHP_SELF .'">';
		echo '<input type="hidden" name="password" value="'. $password .'">';
		echo '<tr><td><b>Player</b></td><td><b>Email</b></td><td><b>Date</b><br>(YYYY-MM-DD)</td><td><b>Count</b></td><td><b>Game ID</b></td></tr>';
		
		$emails = mysql_query("SELECT * FROM hs_emails", $db);
		while ($email = mysql_fetch_array($emails)){
			echo '<tr>';
			echo '<td>'.urldecode($email['player']).'</td>';
			echo '<td>'.urldecode($email['email']).'</td>';
			echo '<td>'.$email['date'].'</td>';
			echo '<td>'.$email['count'].'</td>';
			echo '<td>'.$email['gameid'].'</td>';
			echo '</tr>';
		}
		echo '<tr><td colspan=4 align="center"><input type="submit" name="emails_csv" value="Comma-Separated List"> <input type="submit" name="emails_clear" value="Clear All"> <input type="submit" name="refresh" value="Done"></td></tr>';
		echo '</form></table>';
		
	}else if (isset($emails_csv)){
		
		echo '<table bgcolor="#8ED1BE" cellpadding=6><tr><td bgcolor="#509C86"><span class="large"><b>Harvested Emails</b></span></td></tr>';
		echo '<form method="post" action="'.$PHP_SELF .'">';
		echo '<input type="hidden" name="password" value="'. $password .'">';
		echo '<tr><td>This list can be copy-and-pasted into an email message to send a mass mailing to players of your games. This list does not reflect duplicates (where an email count is higher than 1).</td></tr>';
		echo '<tr><td bgcolor="white" align="center"><textarea rows=10 cols=50 wrap="virtual">';
		
		$arr_emails = array();
		$emails = mysql_query("SELECT * FROM hs_emails", $db);
		while ($email = mysql_fetch_array($emails)){
			array_push($arr_emails, urldecode($email['email']));
		}
		echo join(", ",$arr_emails);
		echo '</textarea></td></tr>';		
		echo '<tr><td align="center"><input type="submit" name="emails_view" value="Done"></td></tr>';
		echo '</form></table>';
		
	}else if (isset($settings_edit)){
		
		$settings = mysql_query("SELECT * FROM hs_settings WHERE id=1", $db);
		$setting = mysql_fetch_array($settings);
		echo '<table bgcolor="#8ED1BE" cellpadding=6><tr><td bgcolor="#509C86" colspan=2><span class="large"><b>Global Settings</b></span></td></tr>';
		echo '<form method="post" action="'.$PHP_SELF .'">';
		echo '<input type="hidden" name="password" value="'. $password .'">';
		echo '<tr><td><b>Your Email Address:</b><span class="small"><br>Your email address is used for sending the high score table to you when it is periodically cleared. Each game has its own settings for whether and how often scores are emailed to you and cleared.</span></td><td><input type="text" size=30 maxlength=80 name="email" value="'. escape_field(urldecode($setting['email'])) .'"></td></tr>';
		echo '<tr><td><b>Edit Bad Words List</b><span class="small"><br>Click this button to edit the list of offensive words that will be automatically censored from player names.</span></td><td><input type="submit" name="badwords_edit" value="Edit Bad Words List"></td></tr>';
		echo '<tr><td><b>Challenge "From" Name</b><span class="small"><br>When a player challenges another, this name will be in the "From" header. For example: "XYZ Games"</span></td><td><input type="text" size=60 maxlength=80 name="challenge_name" value="'. escape_field(urldecode($setting['challenge_name'])) .'"></td></tr>';
		echo '<tr><td><b>Challenge "From" Email</b><span class="small"><br>When a player challenges another, this email address will be in the "From" header. For example: "webmaster@xyzgames.com". If a player replies to their challenge email, the response will be sent here.</span></td><td><input type="text" size=60 maxlength=80 name="challenge_email" value="'. escape_field(urldecode($setting['challenge_email'])) .'"></td></tr>';
		echo '<tr><td colspan=2 align="center"><input type="submit" name="settings_apply" value="Apply"> <input type="submit" name="refresh" value="Cancel"></td></tr>';
		echo '</form></table>';
		
	}else if (isset($badwords_edit)){
		
		mysql_query("UPDATE hs_settings SET email=\"". urlencode($email) ."\" WHERE id=1", $db);
		$wordstrs = mysql_query("SELECT * FROM hs_settings WHERE id=1", $db);
		$wordstr = mysql_fetch_array($wordstrs);
		echo '<table bgcolor="#8ED1BE" cellpadding=6 width="75%"><tr><td bgcolor="#509C86" colspan=5><span class="large"><b>Bad Words</b></span></td></tr>';
		echo '<form method="post" action="'.$PHP_SELF .'">';
		echo '<input type="hidden" name="password" value="'. $password .'">';
		echo '<tr><td>These words will be automatically removed from player names. The system will also detect whitespace between characters, mixed case words, and number substitutions of letters (i.e. will detect words that use a zero instead of an O or a 1 instead of an i).<p><center><textarea name="words" rows=20 cols=50 wrap=virtual>'. urldecode($wordstr['words']) .'</textarea></td></tr>';
		echo '<tr><td align="center"><input type="submit" name="badwords_submit" value="Apply"> <input type="submit" name="settings_edit" value="Cancel"> &nbsp;&nbsp;&nbsp; <input type="submit" name="badwords_test" value="Bad Words Tester"></td></tr>';
		echo '</form></table>';
		
	}else if (isset($badwords_test)){
		
		//$wordstrs = mysql_query("SELECT * FROM hs_settings WHERE id=1", $db);
		//$wordstr = mysql_fetch_array($wordstrs);
		echo '<table bgcolor="#8ED1BE" cellpadding=6><tr><td bgcolor="#509C86" colspan=5><span class="large"><b>Bad Words Tester</b></span></td></tr>';
		echo '<form method="post" action="'.$PHP_SELF .'">';
		echo '<input type="hidden" name="password" value="'. $password .'">';
		echo '<tr><td align="center">Enter a "bad word" to test, and click Test.<p><center><input type="text" name="badword" value="'.$badword.'">';
		if (isset($badword)){
			echo '<p><center>Censored Result:<br><b><nobr>'.censor_word($badword).'</nobr></b></center>';
		}
		echo '</td></tr>';
		echo '<tr><td align="center"><input type="submit" name="badwords_test" value="Test"> <input type="submit" name="badwords_edit" value="Cancel"></td></tr>';
		echo '</form></table>';
		
	}else if (isset($emails_clear)){
		
		echo '<table bgcolor="#8ED1BE" cellpadding=6><tr><td bgcolor="#509C86" class="large" colspan=5><b>Clear All Harvested Emails?</b></td></tr>';
		echo '<form method="post" action="'.$PHP_SELF .'">';
		echo '<input type="hidden" name="password" value="'. $password .'">';
		echo '<tr><td align="center">';
		echo '<input type="submit" name="emails_clear_confirm" value="Yes"> <input type="submit" name="emails_view" value="No">';
		echo '</td></tr>';
		echo '</form></table>';
		
	}else if (isset($view_clear)){
		
		$settings = mysql_query("SELECT * FROM hs_settings WHERE id=1", $db);
		$setting = mysql_fetch_array($settings);	
		echo '<table bgcolor="#8ED1BE" cellpadding=6><tr><td bgcolor="#509C86" class="large" colspan=5><b>Clear All Scores?</b></td></tr>';
		echo '<form method="post" action="'.$PHP_SELF .'">';
		echo '<input type="hidden" name="password" value="'. $password .'">';
		echo '<input type="hidden" name="gameid" value="'. $gameid .'">';
		echo '<tr><td align="center">';
		echo '<input type="submit" name="view_clear_confirm_email" value="Email Scores to \''.urldecode($setting['email']).'\', Then Clear Them"><br>';
		echo '<input type="submit" name="view_clear_confirm" value="Just Clear the Scores"><p>';
		echo '<input type="submit" name="game_view" value="Cancel">';
		echo '</td></tr>';
		echo '</form></table>';
		
	}else if (isset($game_del)){
		
		$games = mysql_query("SELECT * FROM hs_games WHERE id=". $gameid, $db);
		$game = mysql_fetch_array($games);
		echo '<table bgcolor="#8ED1BE" cellpadding=6><tr><td bgcolor="#509C86" class="large"><b>Delete This Game?</b></td></tr>';
		echo '<form method="post" action="'.$PHP_SELF .'">';
		echo '<input type="hidden" name="password" value="'. $password .'">';
		echo '<input type="hidden" name="gameid" value="'. $gameid .'">';
		echo '<tr><td align="center"><b>'. $game['name'] .'</b><p><input type="submit" name="del_confirm" value="Yes"> <input type="submit" name="refresh" value="No"></td></tr>';
		echo '</form></table>';
		
	}else if (isset($game_edit)){
		
		$games = mysql_query("SELECT * FROM hs_games WHERE id=". $gameid, $db);
		$game = mysql_fetch_array($games);
		$settings = mysql_query("SELECT * FROM hs_settings WHERE id=1", $db);
		$setting = mysql_fetch_array($settings);	
		echo '<table bgcolor="#8ED1BE" cellpadding=6 width=600><tr><td bgcolor="#509C86" class="large" colspan=2><b>Edit Game</b></td></tr>';
		echo '<form method="post" action="'.$PHP_SELF .'">';
		echo '<input type="hidden" name="password" value="'. $password .'">';
		echo '<input type="hidden" name="gameid" value="'. $gameid .'">';
	
		echo '<tr><td colspan=2 bgcolor="#6FB6A2">Basic Settings</td></tr>';
		echo '<tr><td><b>Game Name:</b></td><td><input type="text" size=30 maxlength=80 name="name" value="'. escape_field(urldecode($game['name'])) .'"></td></tr>';
		echo '<tr><td><b>Maximum Scores in Table:</b></td><td><input type="text" size=5 maxlength=5 name="maxscores" value="'. escape_field($game['maxscores']) .'"></td></tr>';
		echo '<tr><td><b>Show Score Dates?</b><span class="small"><br>(Whether to display dates for scores on the high score table.)</span></td><td><select name="showdate">';
		echo '<option name="yes"'. ($game['showdate']=="yes"?" selected":"") .'>Yes';
		echo '<option name="no"'. ($game['showdate']=="no"?" selected":"") .'>No';
		echo '</select></td></tr>';
		
		echo '<tr><td colspan=2 bgcolor="#6FB6A2">Score Clearing Settings</td></tr>';
		echo '<tr><td valign="top"><b>Clear Interval:</b><span class="small"><br>(How often the scores should be automatically reset.)</span></td><td valign="top"><select name="clearinterval">';
		echo '<option value="daily"'. ($game['clearinterval']=="daily"?" selected":"") .'>Daily (1 Day)';
		echo '<option value="weekly"'. ($game['clearinterval']=="weekly"?" selected":"") .'>Weekly (7 Days)';
		echo '<option value="monthly"'. ($game['clearinterval']=="monthly"?" selected":"") .'>Monthly (30 Days)';
		echo '<option value="quarterly"'. ($game['clearinterval']=="quarterly"?" selected":"") .'>Quarterly (90 Days)';
		echo '<option value="yearly"'. ($game['clearinterval']=="yearly"?" selected":"") .'>Yearly (365 Days)';
		echo '<option value="never"'. ($game['clearinterval']=="never"?" selected":"") .'>Never Cleared';
		echo '</select></td></tr>';
		$global_email = urldecode($setting['email']);
		if ($global_email == ""){
			$global_email = '<font color="red">NOT SET</font>';
		}else if (!check_email($global_email)){
			$global_email = '<font color="red">NOT VALID</font>';
		}
		echo '<tr><td valign="top"><b>Email Cleared Scores?</b><span class="small"><br>(If enabled, scores will be emailed to you when they are cleared from the database. Scores can\'t be retrieved once cleared. Your email address can be set by clicking Global Settings on the Games screen, and is currently <b>'.$global_email.'</b>.)</span></td><td valign="top"><select name="emailscores">';
		echo '<option name="yes"'. ($game['emailscores']=="yes"?" selected":"") .'>Yes';
		echo '<option name="no"'. ($game['emailscores']=="no"?" selected":"") .'>No';
		echo '</select></td></tr>';
		
		$curr_fields = $game['recordplayeremail']."_".$game['maxchars'];
		echo '<tr><td colspan=2 bgcolor="#6FB6A2">Player Input Settings</td></tr>';
		echo '<tr><td valign="top"><b>Player Info Fields</b><span class="small"><br>(This setting lets you choose what information about a player is recorded, which can either be a name and email address, a name only, or an email address only. If names are disabled, all players will show up as "Anonymous".)</span></td>';
		echo '<td valign="top"><select name="player_fields">';
		echo '<option value="yes_20"'. ($curr_fields=='yes_20'?' selected':'') .'>Email & 20-Char Name';
		echo '<option value="yes_8"'. ($curr_fields=='yes_8'?' selected':'') .'>Email & 8-Char Name';
		echo '<option value="yes_3"'. ($curr_fields=='yes_3'?' selected':'') .'>Email & 3-Char Name';
		echo '<option value="yes_0"'. ($curr_fields=='yes_0'?' selected':'') .'>Email Only';
		echo '<option value="no_20"'. ($curr_fields=='no_20'?' selected':'') .'>20-Char Name';
		echo '<option value="no_8"'. ($curr_fields=='no_8'?' selected':'') .'>8-Char Name';
		echo '<option value="no_3"'. ($curr_fields=='no_3'?' selected':'') .'>3-Char Name';
		echo '<option value="no_0"'. ($curr_fields=='no_0'?' selected':'') .'>None (Anonymous Only)';
		echo '</select></td></tr>';

		/*
		echo '<tr><td valign="top"><b>Max Characters in Player Name</b><span class="small"><br>(This setting lets you choose how long a player name can be, from 3 characters &mdash; arcade style, to 20. If this is set to "Names not Allowed", all players will show up as "Anonymous".)</span></td>';
		echo '<td><select name="maxchars">';
		echo '<option value="0"'. ($game['maxchars']==0?' selected':'') .'>Names not Allowed';
		echo '<option value="3"'. ($game['maxchars']==3?' selected':'') .'>3 Characters';
		echo '<option value="5"'. ($game['maxchars']==5?' selected':'') .'>5 Characters';
		echo '<option value="8"'. ($game['maxchars']==8?' selected':'') .'>8 Characters';
		echo '<option value="10"'. ($game['maxchars']==10?' selected':'') .'>10 Characters';
		echo '<option value="20"'. ($game['maxchars']==20?' selected':'') .'>20 Characters';
		echo '</select></td></tr>';
		echo '<tr><td valign="top"><b>Ask for Player Email Address?</b><span class="small"><br>(If turned on, players will be asked if they want to submit their email address when they are put on the high score table.)</span></td><td><select name="recordplayeremail">';
		echo '<option name="yes"'. ($game['recordplayeremail']=="yes"?" selected":"") .'>Yes';
		echo '<option name="no"'. ($game['recordplayeremail']=="no"?" selected":"") .'>No';
		echo '</select></td></tr>';
		*/
		
		echo '<tr><td valign="top"><b>Always Harvest Email Address?</b><span class="small"><br>(If turned on, players will be asked for their email address even when they don\'t get a high score. This setting may override the one above.)</span></td><td valign="top"><select name="harvest_all_emails">';
		echo '<option name="yes"'. ($game['harvest_all_emails']=="yes"?" selected":"") .'>Yes';
		echo '<option name="no"'. ($game['harvest_all_emails']=="no"?" selected":"") .'>No';
		echo '</select></td></tr>';
		echo '<tr><td valign="top"><b>Name Request Message</b><span class="small"><br>(This message will be shown at the name/email prompt when a high score has been made. For example: "Enter your name and email address for a chance to win our monthly prize!")</span></td>';
		echo '<td valign="top"><textarea name="emailpromptmessage" rows=5 cols=30>'. urldecode($game['emailpromptmessage']) .'</textarea></td></tr>';
		//Enter your email address to be entered into our prize drawing! Your address will be hidden from the public.

		echo '<tr><td valign="top"><b>Low Score Message</b><span class="small"><br>(If the player doesn\'t make it onto the high score table, this message will be displayed. Use a % character to display the score you need to exceed to get a high score. For exmaple, "Score over % points" will become "Score over 1500 points". If <b>Always Harvest Email</b> is turned on, you may want to give the player an additional incentive for entering their email address &mdash; a contest, newsletter, etc.)</span></td>';
		echo '<td valign="top"><textarea name="lowscoremessage" rows=5 cols=30>'. urldecode($game['lowscoremessage']) .'</textarea></td></tr>';
		

		echo '<tr><td colspan=2 bgcolor="#6FB6A2">Challenge Settings</td></tr>';
		echo '<tr><td valign="top"><b>Allow Player to Challenge a Friend</b><span class="small"><br>(If turned on, players can email their score to a friend, encouraging/challenging others to beat their score.)</span></td><td valign="top"><select name="emailtofriend">';
		echo '<option name="yes"'. ($game['emailtofriend']=="yes"?" selected":"") .'>Yes';
		echo '<option name="no"'. ($game['emailtofriend']=="no"?" selected":"") .'>No';
		echo '</select></td></tr>';
		echo '<tr><td valign="top"><b>Game URL</b><span class="small"><br>(If scores are emailed to a player\'s friend, this URL will be used in the email message to direct the friend back to this game. Also, make sure the Game Name setting above is correct, as it will be used in the challenge email.)</span></td>';
		echo '<td valign="top"><input type="text" size=30 maxlength=80 name="gameurl" value="'. escape_field(urldecode($game['gameurl'])) .'"></td></tr>';

		echo '<tr><td align="center" colspan=2><input type="submit" name="game_apply" value="Apply"> <input type="submit" name="refresh" value="Cancel"></td></tr>';
		echo '</form></table>';
		
	}else{//---\/--- DEFAULT VIEW
	
		if (isset($refresh)) unset($gameid);
		if (isset($emails_clear_confirm)){
		
			mysql_query("TRUNCATE TABLE hs_emails", $db);	
		}
		if (isset($view_clear_confirm)){
		
			clear_scores($gameid);
			unset ($gameid);	
		}
		if (isset($view_clear_confirm_email)){
			
			if (email_scores($gameid)) clear_scores($gameid);
			unset ($gameid);	
		}
		if (isset($del_confirm)){
			
			mysql_query("DELETE FROM hs_games WHERE id=". $gameid, $db);
			unset ($gameid);	
		}		
		if (isset($game_apply)){
			
			$scores = mysql_query("SELECT * FROM hs_scores WHERE gameid=". $gameid ." ORDER BY score DESC, date", $db);
			if (mysql_num_rows($scores) > $maxscores){	// need to delete some scores
				$count = 0;
				while ($count < $maxscores){		// eat up scores to save
					$score = mysql_fetch_array($scores);
					$count++;
				}
				while ($score = mysql_fetch_array($scores)){	// delete remaining scores
					mysql_query("DELETE FROM hs_scores WHERE id=". $score['id'], $db);	
				}
			}
			list($curr_recordplayeremail, $curr_maxchars) = explode("_", $player_fields);
			mysql_query("UPDATE hs_games SET name=\"". urlencode($name) ."\", maxscores=". $maxscores .", clearinterval=\"". $clearinterval ."\", emailscores=\"". $emailscores ."\", recordplayeremail=\"". $curr_recordplayeremail ."\", harvest_all_emails=\"". $harvest_all_emails ."\", emailpromptmessage=\"". urlencode($emailpromptmessage) ."\", lowscoremessage=\"". urlencode($lowscoremessage) ."\", maxchars=\"".$curr_maxchars."\", showdate=\"".$showdate."\", emailtofriend=\"".$emailtofriend."\", gameurl=\"".urlencode($gameurl)."\" WHERE id=". $gameid, $db);
			unset($gameid);
		}
		
		if (isset($settings_apply)){
			mysql_query("UPDATE hs_settings SET email='". urlencode($email) ."', challenge_name='". urlencode($challenge_name) ."', challenge_email='". urlencode($challenge_email) ."' WHERE id=1", $db);
		}
		
		if (isset($game_add)){
			mysql_query("INSERT INTO hs_games (name, maxscores, emailpromptmessage, lowscoremessage) VALUES ('-- new game --', 100, '".$def_emailpromptmessage."', '".$def_lowscoremessage."')", $db);
		}
		
		echo '<table bgcolor="#8ED1BE" cellpadding=5><tr><td bgcolor="#509C86" class="large" colspan=10><b>Games</b></td></tr>';
		echo '<tr><td class="small" valign="top"><b>ID</b></td><td class="small" valign="top"><b>Game Name</b></td><td class="small" valign="top" align="center"><b>Num/Max<br>Scores</b></td><td class="small" valign="top" align="center"><b>High Score<br>(Player)</b></td><td class="small" valign="top" align="center"><b>Clear<br>Interval</b></td><td class="small" valign="top" align="center"><b>Email Cleared<br>Scores?</b></td><td class="small" valign="top" align="center"><b>Ask for<br>Player Email?</b></td><td class="small" valign="top" align="center"><b>Harvest All<br>Emails?</b></td><td class="small" valign="top" align="center"><b>Cleared On</b><br>(YYYY-MM-DD)</td><td></td></tr>';
		$games = mysql_query("SELECT * FROM hs_games", $db);
		while ($game = mysql_fetch_array($games)){
			echo '<tr><td colspan=10><hr width="100%" size=1 color="#509C86"></td></tr>';
			//$editing = false;
			//if (isset($gameid) && $gameid == $game['id']) $editing = true;
			echo '<form method="post" action="'.$PHP_SELF .'">';
			echo '<input type="hidden" name="password" value="'. $password .'">';
			echo '<input type="hidden" name="gameid" value="'. $game['id'] .'">';
			echo '<tr class="high_scores"><td>'. $game['id'] .'</td>';
			echo '<td><b>'. urldecode($game['name']) .'</b></td>';
			$scores = mysql_query("SELECT * FROM hs_scores WHERE gameid=". $game['id'] ." ORDER BY score DESC", $db);
			/*
			if ($editing) echo '<td>Max Scores:<br><input type="text" size=5 maxlength=5 name="maxscores" value="'. $game['maxscores'] .'"></td>';
			else 
			*/
			echo '<td align="center">'. mysql_num_rows($scores) .'/'. $game['maxscores'] .'</td>';
			if (mysql_num_rows($scores) > 0){
				$highscore = mysql_fetch_array($scores);
				$debug = true;
				echo '<td nowrap>'. number_format($highscore['score']) .' ('. censor_word(urldecode($highscore['player'])) .')';
				echo '</td>';
			}else{
				echo '<td></td>';
			}
			echo '<td align="center">'. ucfirst($game['clearinterval']) .'</td>';	
			echo '<td align="center">'. ucfirst($game['emailscores']) .'</td>';	
			echo '<td align="center">'. ucfirst($game['recordplayeremail']) .'</td>';	
			echo '<td align="center">'. ucfirst($game['harvest_all_emails']) .'</td>';	
			echo '<td align="center">'. ($game['lastcleared']=="0000-00-00" ? "Never" : $game['lastcleared']) .'</td>';	
			echo '<td nowrap>';
			/*
			if ($editing){
				echo '<input type="submit" value="Apply" name="game_apply"> ';
				echo '<input type="submit" value="Delete Game" name="game_del"> ';
				echo '<input type="submit" value="Cancel" name="refresh"><br>';
			}
			*/
			echo '<input type="submit" value="Edit" name="game_edit"> ';
			echo '<input type="submit" value="Delete" name="game_del"> ';
			echo '<input type="submit" value="Scores" name="game_view">';
			echo '</td></tr></form>';	
		}
		echo '<tr><td colspan=10><hr width="100%" size=1 color="#509C86"></td></tr>';
		
		echo '<form method="post" action="'.$PHP_SELF.'">';
		echo '<input type="hidden" name="password" value="'.$password.'">';
		echo '<tr><td colspan=7>';
		echo '<input type="submit" value="Add a Game" name="game_add">&nbsp;&nbsp;&nbsp;&nbsp;';
		echo '<input type="submit" value="Global Settings" name="settings_edit">&nbsp;&nbsp;&nbsp;&nbsp;';
		echo '<input type="submit" value="Harvested Emails" name="emails_view">&nbsp;&nbsp;&nbsp;&nbsp;';
		echo '<input type="submit" value="Refresh" name="refresh">';
		
		echo '</td></tr></form></table>';
	
	}//---/\--- DEFAULT VIEW
}//---/\--- IF LOGGED IN ---

?>

<!--\/-- footer -->
</td></tr></table>
<table width="100%" bgcolor="#509C86"><tr><td align="right">Copyright &copy;1998-2004 <a href="http://www.eyeland.com/" target="_new"><b>Eyeland Studio</b></a>, Inc.  All Rights Reserved.</td></tr></table>
<!-- Copyright (c)1998-2004 Eyeland Studio, Inc.  All Rights Reserved. -->
</body></html>
