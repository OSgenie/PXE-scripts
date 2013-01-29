#!/bin/bash
# Kirtley Wienbroer
# kirtley@osgenie.com
# June 24 2012

function check_for_sudo ()
{
if [ $UID != 0 ]; then
		echo "You need root privileges"
		exit 2
fi
}

check_for_sudo

tftpfolder=/var/lib/tftpboot
rm $tftpfolder/menus/*.conf

menusarray=$( ls $tftpfolder/menus )
for folder in $menusarray
do
echo $folder
menupath="$tftpfolder/menus/$folder.conf"
echo "MENU TITLE --== $folder Menu ==--" > $menupath
echo " " >> $menupath
echo "LABEL rootmenu" >> $menupath
echo "        MENU LABEL <---- Main Menu" >> $menupath
echo "        kernel vesamenu.c32" >> $menupath
echo "        append mainmenu.conf" >> $menupath
echo " " >> $menupath

	for conf in $tftpfolder/menus/$folder/*
	do 
	fullname=$(basename $conf)
	extension=${fullname##*.}
	name=$(basename $conf .$extension)
	if [ $extension = conf ]; then
		echo $fullname
		echo "LABEL $name" >> $menupath
		echo "        MENU LABEL $name --->" >> $menupath
		echo "        kernel vesamenu.c32" >> $menupath
		echo "        append /menus/$folder/$fullname" >> $menupath
		echo "" >> $menupath
	fi
	done
done