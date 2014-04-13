<?php 	
require_once "database.inc.php";

	mysql_query("DELETE from `lschannels-ru`")
        or die(mysql_error()); 

	mysql_query("DELETE from programmes")
	or die(mysql_error()); 

	mysql_query("DELETE from channels")
	or die(mysql_error()); 
	sleep(10);
?>
