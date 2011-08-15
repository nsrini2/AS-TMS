<?php

$sql_username = "highscore";
// Replace this value with the username for your MySQL login

$sql_password = "smile@1";
// Replace this value with the password for your MySQL login

$sql_hostname = "tnssdb01.aln.sabre.com";
// Replace this value with the hostname/ip address of the MySQL server
// to connect to. (Sometimes this is "localhost".)

$sql_database = "high_score";
// Replace this value with the name of the database that the above
// username and password will be working on (and will have access to).

$hs_password = "D34lsTacos&Extr4s";
// Set this value to the password you'd like to use to protect
// the high score manager system from unauthorized access.
// A blank value ($hs_password = "";) disables the need for a password

$hostname_giaf_hs = $sql_hostname;
$database_giaf_hs = $sql_database;
$username_giaf_hs = $sql_username;
$password_giaf_hs = $sql_password;
$giaf_hs = mysql_pconnect($hostname_giaf_hs, $username_giaf_hs, $password_giaf_hs) or trigger_error(mysql_error(),E_USER_ERROR); 
?>