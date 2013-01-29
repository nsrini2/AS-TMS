<?php

include "hs_global.php";
include $login_file;

$gid = $_GET['gid'];
if($gid == ""){
$gid = 1;
}

mysql_select_db($database_giaf_hs, $giaf_hs);
$query_rs_scores = "SELECT * FROM hs_scores WHERE gameid LIKE " . $gid . " order by 'score' desc";
$rs_scores = mysql_query($query_rs_scores, $giaf_hs) or die(mysql_error());
$row_rs_scores = mysql_fetch_assoc($rs_scores);
$totalRows_rs_scores = mysql_num_rows($rs_scores);

mysql_select_db($database_giaf_hs, $giaf_hs);
$query_rs_games = "SELECT * FROM hs_games";
$rs_games = mysql_query($query_rs_games, $giaf_hs) or die(mysql_error());
$row_rs_games = mysql_fetch_assoc($rs_games);
$totalRows_rs_scores = mysql_num_rows($rs_games);
?>
<html>
<head>
<title>High Scores</title>
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

<body>
<table width="500" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td><table width="500" border="0" cellspacing="0" cellpadding="3">
      <tr bgcolor="#8ED1BE">
        <td colspan="3"><b><a href="http://www.gamesinaflash.com/" target="_new">Games In A Flash</a><br>
            <span class="large">&nbsp;High Score Display </span></b></td>
        </tr>
      <tr bgcolor="#8ED1BE">
        <td colspan="3"><form action="hs_display.php" method="get" name="frmGetGame" id="frmGetGame">
          <table width="400" border="0" cellspacing="0" cellpadding="0">
            <tr>
              <td align="right">choose game: </td>
              <td><select name="gid" id="gid">
                <?php
do {  
?>
                <option value="<?php echo $row_rs_games['id']; ?>" <?php if($row_rs_games['id'] == $gid) { echo "selected"; } ?>><?php echo urldecode($row_rs_games['name']); ?></option>
                <?php
} while ($row_rs_games = mysql_fetch_assoc($rs_games));
  $rows = mysql_num_rows($rs_games);
  if($rows > 0) {
      mysql_data_seek($rs_games, 0);
	  $row_rs_games = mysql_fetch_assoc($rs_games);
  }
?>
              </select>&nbsp;&nbsp;<input type="submit" name="Submit" value="Go"></td>
              </tr>
          </table>
        </form></td>
      </tr>
      <tr bgcolor="#7097AD">
        <td><font color="#FFFFFF"><strong>Player</strong></font></td>
        <td><font color="#FFFFFF"><strong>Score</strong></font></td>
        <td><font color="#FFFFFF"><strong>Date</strong></font></td>
      </tr>
      <?php 
		$bg = "#CCCCCC";
		do { ?>
      <tr bgcolor="<?php echo $bg; ?>">
          <td><?php echo urldecode($row_rs_scores['player']); ?></td>
          <td><?php echo $row_rs_scores['score']; ?></td>
          <td><?php echo $row_rs_scores['date']; ?></td>
      </tr>
		<?php if($bg == "#CCCCCC") { $bg = "#FFFFFF"; } else { $bg = "#CCCCCC"; } ?>
      <?php } while ($row_rs_scores = mysql_fetch_assoc($rs_scores)); ?>
    </table></td>
  </tr>
</table>
</body>
</html>
<?php
mysql_free_result($rs_scores);
?>
