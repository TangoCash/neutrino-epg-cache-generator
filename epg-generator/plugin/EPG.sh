#!/bin/sh

mem_limit="100"
sch_str="epg_dir"
file_url="http://epg_archive_source/"
file_name="epg.tar.gz"
file_conf="/var/tuxbox/config/neutrino.conf"

if [ -d /tmp ]
then
tmp_dir="/tmp"
fi

if [ -d /temp ]
then
tmp_dir="/temp"
fi

echo `cat $file_conf | grep $sch_str` > $tmp_dir/conf
source $tmp_dir/conf
psize=${#epg_dir}

if [ $psize -eq 0 ]
then
echo "EPG path variable not set or not found, aborting!"
exit
fi

if [ ! -d $epg_dir ]
then
echo "EPG path not found, aborting!"
exit
fi

free_mem=`df -m $epg_dir | tail -1 | awk '{print $4}'`

if [ $free_mem -lt $mem_limit ]
then
echo "Not enough space for EPG files, aborting!"
exit
fi

echo "Getting new file from server..."
wget -qO $tmp_dir/$file_name $file_url$file_name

if [ ! -f $tmp_dir/$file_name ]
then
echo "EPG data file not found, aborting!"
exit
fi

if [ ! -d $epg_dir$tmp_dir ]
then
mkdir $epg_dir$tmp_dir
fi

echo "Removing old files..."
rm $epg_dir/*.*
rm $epg_dir$tmp_dir/*.*

echo "Unpacking..."
cd $epg_dir$tmp_dir
tar -xzf $tmp_dir/$file_name
rm $tmp_dir/$file_name

# Heavily depend on Neutrino internal stuff - may break at any moment

echo "Getting channels list..."
bq=`pzapit | grep ther |  awk '{print $1}'`
size=${#bq}
if [ $size -lt 3 ]
then 
bq=`echo $bq | cut -c1`
else
bq=`echo $bq | cut -c1-2`
fi

wget -q -O $tmp_dir/channels http://127.0.0.1/y/cgi?execute=func:get_channels_as_dropdown%20$bq
 
for f in `cut -c19-30 $tmp_dir/channels`; do
echo $f".xml" >> $tmp_dir/files 
done
echo "Moving actual data..."
for f in `cat $tmp_dir/files`; do
mv $epg_dir$tmp_dir/$f $epg_dir > /dev/null 2>&1
done
echo "Generating index file..."
cd $epg_dir
ls -p | grep -v / > $tmp_dir/files
echo '<?xml version="1.0" encoding="UTF-8"?>' > index.xml
echo "<dvbepgfiles>" >> index.xml
for f in `cat $tmp_dir/files`; do
echo "<eventfile name=\""$f"\"/>" >> index.xml
done
echo "</dvbepgfiles>" >> index.xml

echo "Clean up..."
rm $epg_dir$tmp_dir/*.*

echo "Start reloading EPG data, this can take some time..."
sectionsdcontrol --readepg $epg_dir

echo "Done!"
exit
