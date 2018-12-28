#!/usr/bin/env bash
# Kirtley Wienbroer
# kirtley@osgenie.com
# June 24 2012

tftp_folder=/var/lib/tftpboot/utilities

echo "MENU TITLE --== Main Menu ==--" > $tftp_folder/menus/"utilities.conf"
echo "TIMEOUT 100 #this is optional - will start the default after 10 seconds" >> $tftp_folder/menus/"utilities.conf"
echo "default bootlocal" >> $tftp_folder/menus/"utilities.conf"
echo "" >> $tftp_folder/menus/"utilities.conf"
echo "#this allows you to exit the pxe stack and pass booting to the local system" >> $tftp_folder/menus/"utilities.conf"
echo "LABEL bootlocal" >> $tftp_folder/menus/"utilities.conf"
echo "        MENU DEFAULT" >> $tftp_folder/menus/"utilities.conf"
echo "        MENU LABEL Local Boot" >> $tftp_folder/menus/"utilities.conf"
echo "        localboot 0" >> $tftp_folder/menus/"utilities.conf"
echo "" >> $tftp_folder/menus/"utilities.conf"

	for subfolder in $tftp_folder/*
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
			echo "LABEL $name" >> $tftp_folder/menus/"utilities.conf"
			echo "        MENU LABEL $name --->" >> $tftp_folder/menus/"utilities.conf"
			echo "        kernel ubuntu-installer/i386/boot-screens/vesamenu.c32" >> $tftp_folder/menus/"utilities.conf"
			echo "        append utilities/$foldername/$fullname" >> $tftp_folder/menus/"utilities.conf"
			echo "" >> $tftp_folder/menus/"utilities.conf"
		else
		echo "No conf files"	
		fi
		done
	done