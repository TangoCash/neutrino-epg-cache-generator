#!/bin/sh

tmp_dir="/tmp"
mem_limit="100"
file_url="http://epg_source/"
file_name="epg.tar.gz"
file_conf="/var/tuxbox/config/neutrino.conf"


echo `cat $file_conf | grep epg_dir` > $tmp_dir/conf
source $tmp_dir/conf
psize=${#epg_dir}

if [ $psize -eq 0 ]
then
echo "EPG path variable not set or not found, aborting!"
exit 1
fi

if [ ! -d $epg_dir ]
then
echo "EPG path not found, aborting!"
exit 1
fi

free_mem=`df -m $epg_dir | tail -1 | awk '{print $4}'`

if [ $free_mem -lt $mem_limit ]
then
echo "Not enough space for EPG files, aborting!"
exit 1
fi

echo "Getting new file from server..."
wget -qP $tmp_dir/ $file_url$file_name

if [ ! -f $tmp_dir/$file_name ]
then
echo "EPG data file not found, aborting!"
exit 1
fi

if [ ! -d $epg_dir/$tmp_dir ]
then
mkdir $epg_dir/$tmp_dir
fi

echo "Removing old files..."
rm $epg_dir/*.*
rm $epg_dir/$tmp_dir/*.*

echo "Unpacking..."
cd $epg_dir/$tmp_dir/
tar -xzf $tmp_dir/$file_name

rm $tmp_dir/$file_name

echo "Start reloading EPG data, this can take some time..."
sectionsdcontrol --readepg $epg_dir/$tmp_dir

echo "Done!"
exit 0