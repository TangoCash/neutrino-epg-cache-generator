<?php 	
	$tmp_dir="/var/tmp/";
	$epg_path="epg/";
	$source_file="channels.xml";

	$db_host = "localhost";
	$db_user = "TVprg";
	$db_passw = "000";
	$db_dbname = "TVprg";

	$db = mysql_connect($db_host, $db_user, $db_passw)
	        or die("Could not connect : " . mysql_error());
	mysql_select_db($db_dbname) or die("Could not select database");
?>
