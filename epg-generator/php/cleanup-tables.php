<?php 	
require_once "database.inc.php";

#removing empty uri's

$sql = "delete from `lschannels-ru` where tvuri=\"\"";
$retval = mysql_query( $sql );
if(! $retval )
{
  die('Could not enter data: ' . mysql_error());
}

#removing malforming filenames

$sql = "delete from `lschannels-ru` where LENGTH(fname)<>16";
$retval = mysql_query( $sql );
if(! $retval )
{
  die('Could not enter data: ' . mysql_error());
}

#removing quotes

$sql = "update programmes set title=REPLACE(title, '\"', ''), text=REPLACE(text, '\"', '')";
$retval = mysql_query( $sql );
if(! $retval )
{
  die('Could not enter data: ' . mysql_error());
}

#replace UTF character with simple "e" (should i do this properly in php script?)

$sql = "update programmes set text=REPLACE(text, '&Eacute', 'é')";
$retval = mysql_query( $sql );
if(! $retval )
{
  die('Could not enter data: ' . mysql_error());
}

#replace ampersand character - Neutrino don't like it

$sql = "update programmes set text=REPLACE(text, '&', ' and '), title=REPLACE(title, '&', ' and ')";
$retval = mysql_query( $sql );
if(! $retval )
{
  die('Could not enter data: ' . mysql_error());
}

?>
