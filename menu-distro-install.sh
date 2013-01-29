#!/bin/bash
# Kirtley Wienbroer
# kirtley@osgenie.com
# Generate PXE boot isodistro from extracted isos

function check_for_sudo ()
{
if [ $UID != 0 ]; then
		echo "You need root privileges"
		exit 2
fi
}

nfshost=192.168.11.3
nfspath=$nfshost:/pxeboot/
nfsrootpath=$nfshost:/var/nfs/pxeboot
tftpfolder=/var/lib/tftpboot
seedpath=http://192.168.11.10/preseed
seedfile="ubuntu.seed"

mount -t nfs4 $nfspath /mnt/
for folder in /mnt/stock/*; do
distro=$(basename "$folder")
menupath="$tftpfolder/menus/install/$distro.conf"
# create distro PXE boot menu
echo "creating $distro menu..."
cat > $menupath << EOM
MENU TITLE --== $distro ==-- 
 
LABEL rootmenu
        MENU LABEL <---- Install Menu
        kernel ubuntu-installer/i386/boot-screens/vesamenu.c32
        append menus/install.conf

EOM
	# PXE boot menu entry for each iso
	revisionarray=$( ls -r $folder )
	for revision in $revisionarray
	do
	if [ ! "$revision" = "stock" ]; then
	revdate=$(date --rfc-3339=seconds -d @$revision)
	else
	revdate=$revision
	fi
	subfolderarray=$folder/$revision
		for subfolder in $subfolderarray; do
		revision=$(basename "$subfolder")
		bootfolder=isodistro/$distro/$revision
		if [ -e "$subfolder/casper/initrd.lz" ]; then
			kernelpath=$bootfolder/casper
		  	echo "$revision - casper!"
		  	mkdir -p $tftpfolder/$kernelpath
			cp -uv $subfolder/casper/vmlinuz $tftpfolder/$kernelpath/
			cp -uv $subfolder/casper/initrd.lz $tftpfolder/$kernelpath/
			cat >> $menupath << EOM
LABEL $revdate
MENU LABEL $revdate
    kernel $kernelpath/vmlinuz
    append initrd=$kernelpath/initrd.lz noprompt boot=casper only-ubiquity url=$seedpath/$seedfile oem-config/enable=true netboot=nfs nfsroot=$nfsrootpath/$distro/$revision ro toram -
EOM
		elif [ -e "$subfolder/casper/initrd.gz" ]; then
			kernelpath=$bootfolder/casper
		  	echo "$revision - casper!"
		  	mkdir -p $tftpfolder/$kernelpath
			cp -uv $subfolder/casper/vmlinuz $tftpfolder/$kernelpath/
			cp -uv $subfolder/casper/initrd.gz $tftpfolder/$kernelpath/
			cat >> $menupath << EOM
LABEL $revdate
MENU LABEL $revdate
    kernel $kernelpath/vmlinuz
    append initrd=$kernelpath/initrd.gz noprompt boot=casper only-ubiquity url=$seedpath/$seedfile oem-config/enable=true netboot=nfs nfsroot=$nfsrootpath/$distro/$revision ro toram -

EOM
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
		  cat >> $menupath << EOM
LABEL $revdate
MENU LABEL $revdate
    kernel $kernelpath/linux
    append initrd=$kernelpath/initrd.gz noprompt netboot=nfs url=$seedpath/$seedfile root=/dev/nfs nfsroot=$nfspath/$distro/$revision/ ip=dhcp rw

EOM
		else 
		  echo "ERROR - $distro-$revision"
		fi
		done
	done
done
umount /mnt/