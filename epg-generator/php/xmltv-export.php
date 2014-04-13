<?php
require_once "database.inc.php";

$sql = "select distinct fname ".
 	"from ((`lschannels-ru` join `channels`) join `programmes`) where ((`lschannels-ru`.`tvuri` = `channels`.`tvuri`) ".
	"and (`channels`.`id` = `programmes`.`channel`))";

$retval = mysql_query($sql);
if(! $retval )
{
  die('Could not get data: ' . mysql_error());
}

$num_rows = mysql_num_rows($retval);
for ($i=0;$i<$num_rows;$i++) {
		$row = mysql_fetch_assoc($retval);
		$ID = $row['fname'];
$f = fopen($tmp_dir.$epg_path.$ID, "w");
	fwrite($f,'<?xml version="1.0" encoding="UTF-8"?>
	<dvbepg>');
	fwrite($f,"\n");
ob_start();
fill_template($ID);
$contents = ob_get_contents();
ob_end_clean();
	fwrite($f,$contents);
	fwrite($f,'</service>');
fwrite($f,"\n");
	fwrite($f,'</dvbepg>');
	fwrite($f,"\n");
fclose($f);
}

function fill_template($fname){
	$q = "select distinct `lschannels-ru`.`tsid` AS `tsid`,`lschannels-ru`.`onid` AS `onid`,".
	"`lschannels-ru`.`sid` AS `sid`,`lschannels-ru`.`fname` AS `fname`, `programmes`.`id` as `evID`,`programmes`.`title` AS `name`,".
	"`programmes`.`text` AS `extended_text`,`programmes`.`begintime` AS `start_time`,".
	"(`programmes`.`endtime` - `programmes`.`begintime`) AS `duration` ".
 	"from ((`channels` join `lschannels-ru`) join `programmes`) where ((`channels`.`tvuri` = `lschannels-ru`.`tvuri`) ".
	"and (`channels`.`id` = `programmes`.`channel`)) and fname=\"$fname\"";

	$r = mysql_query($q);
if(! $r )
{
  die('Could not get data: ' . mysql_error());
}

	$num_rows = mysql_num_rows($r);
	$row = mysql_fetch_assoc($r);
	$tsid = $row['tsid'];
	$onid = $row['onid'];
	$sid = $row['sid'];
Print "<service original_network_id=\"$onid\" transport_stream_id=\"$tsid\" service_id=\"$sid\">\n";

for ($i=1;$i<$num_rows;$i++) {
	$row = mysql_fetch_assoc($r);
	$name = $row['name'];
	$extended_text = str_replace('\\n',''.PHP_EOL.'',$row['extended_text']);
	$start_time = $row['start_time'];
	$duration = $row['duration'];
	$evid=$row['evID'];

Print "		<event id=\"$evid\">
			<name lang=\"rus\" string=\"$name\"/>
			<extended_text lang=\"rus\" string=\"$extended_text\"/>
			<time start_time=\"$start_time\" duration=\"$duration\"/>
		</event>\n";
}
}
?>