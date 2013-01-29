#!/bin/bash
# Kirtley Wienbroer
# kirtley@osgenie.com
# June 24 2012
# Generate PXE boot isodistro from extracted isos

function check_for_sudo ()
{
if [ $UID != 0 ]; then
		echo "You need root privileges"
		exit 2
fi
}

check_for_sudo

nfshost=192.168.11.88
nfspath=$nfshost:/pxeboot
nfsrootpath=$nfshost:/var/nfs/pxeboot
tftpfolder=/var/lib/tftpboot
seedpath=http://192.168.11.10/preseed
seedfile="ubuntu.seed"

mount -t nfs4 $nfspath /mnt/pxeboot
for folder in /mnt/pxeboot/*
do
distro=$(basename "$folder")
menupath="$tftpfolder/menus/install/$distro.conf"
# create distro PXE boot menu
echo "creating $distro menu..."
echo "MENU TITLE --== $distro ==-- " > $menupath
echo " " >> $menupath
echo "LABEL rootmenu" >> $menupath
echo "        MENU LABEL <---- Install Menu" >> $menupath
echo "        kernel ubuntu-installer/i386/boot-screens/vesamenu.c32" >> $menupath
echo "        append menus/install.conf" >> $menupath
echo " " >> $menupath


	# PXE boot menu entry for each iso
	revisionarray=$( ls -r $folder )
	for revision in $revisionarray
	do
	if [ ! "$revision" = "stock" ];then
	revdate=$(date --rfc-3339=seconds -d @$revision)
	else
	revdate=$revision
	fi
	subfolderarray=$folder/$revision
		for subfolder in $subfolderarray
		do
		revision=$(basename "$subfolder")
		bootfolder=isodistro/$distro/$revision
		if [ -e "$subfolder/casper/initrd.lz" ]; then
			kernelpath=$bootfolder/casper
		  	echo "$revision - casper!"
		  	mkdir -p $tftpfolder/$kernelpath
			cp -uv $subfolder/casper/vmlinuz $tftpfolder/$kernelpath/
			cp -uv $subfolder/casper/initrd.lz $tftpfolder/$kernelpath/
		  echo "LABEL $revdate" >> $menupath
		  echo "	MENU LABEL $revdate" >> $menupath
		  echo "	kernel $kernelpath/vmlinuz" >> $menupath
		  echo "	append initrd=$kernelpath/initrd.lz noprompt boot=casper only-ubiquity url=$seedpath/$seedfile oem-config/enable=true netboot=nfs nfsroot=$nfsrootpath/$distro/$revision ro toram -" >> $menupath
		  echo " " >> $menupath
		elif [ -e "$subfolder/casper/initrd.gz" ]; then
			kernelpath=$bootfolder/casper
		  	echo "$revision - casper!"
		  	mkdir -p $tftpfolder/$kernelpath
			cp -uv $subfolder/casper/vmlinuz $tftpfolder/$kernelpath/
			cp -uv $subfolder/casper/initrd.gz $tftpfolder/$kernelpath/
		  echo "LABEL $revdate" >> $menupath
		  echo "	MENU LABEL $revdate" >> $menupath
		  echo "	kernel $kernelpath/vmlinuz" >> $menupath
		  echo "	append initrd=$kernelpath/initrd.gz noprompt boot=casper only-ubiquity url=$seedpath/$seedfile oem-config/enable=true netboot=nfs nfsroot=$nfsrootpath/$distro/$revision ro toram -" >> $menupath
		  echo " " >> $menupath
		elif [ -e "$subfolder/install" ]; then
		  if [[ $distro == *amd64* ]]; then
		  cpu=amd64
		  else
		  cpu=i386
		  fi
		  kernelpath=$bootfolder/install/netboot/ubuntu-installer/$cpu
		  echo "$revision - install!"
		  mkdir -p $tftpfolder/$kernelpath
		  cp -uv $subfolder/install/netboot/ubuntu-installer/$cpu/linux $tftpfolder/$kernelpath/
		  cp -uv $subfolder/install/netboot/ubuntu-installer/$cpu/initrd.gz $tftpfolder/$kernelpath/
		  
		  echo "LABEL $revdate" >> $menupath
		  echo "	MENU LABEL $revdate" >> $menupath
		  echo "	kernel $kernelpath/linux" >> $menupath
		  echo "	append initrd=$kernelpath/initrd.gz noprompt netboot=nfs url=$seedpath/$seedfile root=/dev/nfs nfsroot=$nfspath/$distro/$revision/ ip=dhcp rw" >> $menupath
		  echo " " >> $menupath
		else 
		  echo "ERROR - $distro-$revision"
		fi
		done
	done
done
umount /mnt/pxeboot
#/mnt/share/ubuntu/ubuntu-10.04.2-server-amd64/install/netboot/ubuntu-installer/amd64/linux
#noprompt cdrom-detect/try-usb=true file=/cdrom/preseed/auto.seed boot=casper only-ubiquity initrd=/casper/initrd.lz oem-config/enable=true automatic-ubiquity splash quiet toram
