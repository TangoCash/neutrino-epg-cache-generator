<?php 	
require_once "database.inc.php";

    $channels = simplexml_load_file($tmp_dir.$source_file);
    foreach ($channels as $channelsinfo):
        $chan=$channelsinfo;
        $title=$channelsinfo['id'];
	$parsed=preg_split('/[:]/', $chan);
	$onid=strtolower(c_var($parsed[5]));
	$tsid=strtolower(c_var($parsed[4]));
	$sid=strtolower(c_var($parsed[3]));
	$fname=$tsid.$onid.$sid.".xml";

$sql = "INSERT INTO `lschannels-ru` ".
       "(tvuri,tsid, onid, sid, fname) ".
       "VALUES('$title', '$tsid', '$onid', '$sid', '$fname')";
$retval = mysql_query( $sql );
if(! $retval )
{
  die('Could not enter data: ' . mysql_error());
}
    endforeach;


function c_var ($link) {
		if (strlen ($link) === 1) {
			return "000".$link;
		} else {
             		if (strlen ($link) === 2) {
			return "00".$link;
		} else
			if (strlen ($link) === 3) {
			return "0".$link;
		} else
			return $link;
		}
	}

?>
