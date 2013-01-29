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
nfspath=$nfshost:/pxeboot/stock
nfsrootpath=$nfshost:/var/nfs/pxeboot/stock
tftpfolder=/var/lib/tftpboot
seedpath=http://192.168.11.10/preseed
seedfile="ubuntu.seed"

mount -t nfs4 $nfspath /mnt/pxeboot
for folder in /mnt/stock/*
do
distro=$(basename "$folder")
menupath="$tftpfolder/menus/stock/$distro.conf"
# create distro PXE boot menu
echo "creating $distro menu..."
echo "MENU TITLE --== $distro ==-- " > $menupath
echo " " >> $menupath
echo "LABEL rootmenu" >> $menupath
echo "        MENU LABEL <---- Stock Menu" >> $menupath
echo "        kernel vesamenu.c32" >> $menupath
echo "        append menus/stock.conf" >> $menupath
echo " " >> $menupath

	# PXE boot menu entry for each iso
	revisionarray=$( ls -r $folder )
	for revision in $revisionarray
	do
	subfolderarray=$folder/$revision
		for subfolder in $subfolderarray
		do
		revision=$(basename "$subfolder")
		bootfolder=isodistro/stock/$distro/$revision
		if [ -e "$subfolder/casper/initrd.lz" ]; then
			kernelpath=$bootfolder/casper
		  	echo "$revision - casper!"
		  	mkdir -p $tftpfolder/$kernelpath
			cp -uv $subfolder/casper/vmlinuz $tftpfolder/$kernelpath/
			cp -uv $subfolder/casper/initrd.lz $tftpfolder/$kernelpath/
		  echo "LABEL "$revision >> $menupath
		  echo "	MENU LABEL "$revision >> $menupath
		  echo "	kernel $kernelpath/vmlinuz" >> $menupath
		  echo "	append initrd=$kernelpath/initrd.lz noprompt boot=casper url=$seedpath/$seedfile netboot=nfs nfsroot=$nfsrootpath/$distro/$revision ro toram -" >> $menupath
		  echo " " >> $menupath
		elif [ -e "$subfolder/casper/initrd.gz" ]; then
			kernelpath=$bootfolder/casper
		  	echo "$revision - casper!"
		  	mkdir -p $tftpfolder/$kernelpath
			cp -uv $subfolder/casper/vmlinuz $tftpfolder/$kernelpath/
			cp -uv $subfolder/casper/initrd.gz $tftpfolder/$kernelpath/
		  echo "LABEL "$revision >> $menupath
		  echo "	MENU LABEL "$revision >> $menupath
		  echo "	kernel $kernelpath/vmlinuz" >> $menupath
		  echo "	append initrd=$kernelpath/initrd.gz noprompt boot=casper url=$seedpath/$seedfile netboot=nfs nfsroot=$nfsrootpath/$distro/$revision ro toram -" >> $menupath
		  echo " " >> $menupath	
		elif [ -e "$subfolder/install" ]; then
		  if [[ $distro == *amd64* ]]; then
		      cpu=amd64
		  elif [[ $distro == *i386* ]]; then
		      cpu=i386
		  else
		      break
		  fi
		  kernelpath=$bootfolder/install/netboot/ubuntu-installer/$cpu
		  echo "$revision - install!"
		  mkdir -p $tftpfolder/$kernelpath
		  cp -uv $subfolder/install/netboot/ubuntu-installer/$cpu/linux $tftpfolder/$kernelpath/
		  cp -uv $subfolder/install/netboot/ubuntu-installer/$cpu/initrd.gz $tftpfolder/$kernelpath/
		  
		  echo "LABEL "$revision >> $menupath
		  echo "	MENU LABEL "$revision >> $menupath
		  echo "	kernel $kernelpath/linux" >> $menupath
		  echo "	append initrd=$kernelpath/initrd.gz noprompt netboot=nfs url=$seedpath/$seedfile root=/dev/nfs nfsroot=$nfspath/$distro/$revision/ ip=dhcp rw" >> $menupath
		  echo " " >> $menupath
		else 
		  echo "ERROR - $distro-$revision"
		  rm $menupath  
		fi
		done
	done
done
umount /mnt/
