#!/usr/bin/env bash
# Kirtley Wienbroer
# kirtley@osgenie.com
# June 24 2012

tftpfolder=/var/lib/tftpboot/utilities

echo "MENU TITLE --== Main Menu ==--" > $tftpfolder/menus/"utilities.conf"
echo "TIMEOUT 100 #this is optional - will start the default after 10 seconds" >> $tftpfolder/menus/"utilities.conf"
echo "default bootlocal" >> $tftpfolder/menus/"utilities.conf"
echo "" >> $tftpfolder/menus/"utilities.conf"
echo "#this allows you to exit the pxe stack and pass booting to the local system" >> $tftpfolder/menus/"utilities.conf"
echo "LABEL bootlocal" >> $tftpfolder/menus/"utilities.conf"
echo "        MENU DEFAULT" >> $tftpfolder/menus/"utilities.conf"
echo "        MENU LABEL Local Boot" >> $tftpfolder/menus/"utilities.conf"
echo "        localboot 0" >> $tftpfolder/menus/"utilities.conf"
echo "" >> $tftpfolder/menus/"utilities.conf"

	for subfolder in $tftpfolder/*
	do
	directory=$(dirname $subfolder)
	foldername=$(basename "$subfolder")
		for conf in $subfolder/*
		do 
		fullname=$(basename $conf)
		extension=${fullname##*.}
		name=$(basename $conf .$extension)
		if [ $extension = conf ]; then
			echo $fullname
			echo "LABEL $name" >> $tftpfolder/menus/"utilities.conf"
			echo "        MENU LABEL $name --->" >> $tftpfolder/menus/"utilities.conf"
			echo "        kernel ubuntu-installer/i386/boot-screens/vesamenu.c32" >> $tftpfolder/menus/"utilities.conf"
			echo "        append utilities/$foldername/$fullname" >> $tftpfolder/menus/"utilities.conf"
			echo "" >> $tftpfolder/menus/"utilities.conf"
		else
		echo "No conf files"	
		fi
		done
	done