#!/bin/sh

root_dir="/home/xmltv"
php_dir="php"
tmp_dir="/var/tmp"
epg_dir="epg"
output_dir="/var/www"
xml_source="http://xmltv_files_source_site"

# Pay attention to .gz files name - inner part will be used later!
xml_epg_file="tvprogram.xml.gz"
xml_ref_file="channels.xml.gz"

date
echo "Getting xml files from server..."
wget -P $tmp_dir/ $xml_source/$xml_ref_file
wget -P $tmp_dir/ $xml_source/$xml_epg_file

echo "Unpacking..."
gzip -d $tmp_dir/$xml_ref_file $tmp_dir/$xml_epg_file

echo "Preparing DB..."
php -f $root_dir/$php_dir/clear-db.php

echo "Fill up DB, this can take some time..."
php -f $root_dir/$php_dir/fill-db.php
$root_dir/xmltv-import.pl <$tmp_dir/tvprogram.xml
php -f $root_dir/$php_dir/cleanup-tables.php

echo "Exporting to Neutrino EPG files..."
if [ ! -d $tmp_dir/$epg_dir ]
then
mkdir -p $tmp_dir/$epg_dir
fi
rm $tmp_dir/$epg_dir/*
php -f $root_dir/$php_dir/xmltv-export.php > /dev/null 2>&1

echo "Generating index file..."
cd $tmp_dir/$epg_dir
ls -1 | tr '\n' '\0' | xargs -0 -n 1 basename > $tmp_dir/files
echo '<?xml version="1.0" encoding="UTF-8"?>' > index.xml
echo "<dvbepgfiles>" >> index.xml
for f in `cat $tmp_dir/files`; do
echo "<eventfile name=\""$f"\"/>" >> index.xml
done
echo "</dvbepgfiles>" >> index.xml

echo "Packing EPG to archive..."
cd $tmp_dir/$epg_dir
tar -czf $output_dir/epg.tar.gz *

echo "Clean up..."
rm $tmp_dir/files
rm $tmp_dir/$epg_dir/*
rm $tmp_dir/*.xml

echo "Done!"
exit 0
