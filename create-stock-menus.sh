#!/usr/bin/env bash
# Kirtley Wienbroer
# kirtley@osgenie.com
nfshost=192.168.11.10
nfspath=$nfshost:/pxeboot/stock
nfsrootpath=$nfshost:/var/nfs/pxeboot/stock
tftpfolder=/var/lib/tftpboot
seedpath=http://192.168.11.10/stock
seedfile="ubuntu.seed"

function check_for_sudo ()
{
if [ $UID != 0 ]; then
		echo "You need root privileges"
		exit 2
fi
}

function distro_title ()
{
cat > $menupath << EOM
MENU TITLE --== $distro ==--
LABEL rootmenu
MENU LABEL <---- Stock Menu
    kernel vesamenu.c32
    append menus/stock.conf

EOM
}

function stock_casper_initrd_lz ()
{
kernelpath=$bootfolder/casper
mkdir -p $tftpfolder/$kernelpath
cp -uv $subfolder/casper/vmlinuz $tftpfolder/$kernelpath/
cp -uv $subfolder/casper/initrd.lz $tftpfolder/$kernelpath/
cat >> $menupath << EOM
LABEL $revision
MENU LABEL $revision
    kernel $kernelpath/vmlinuz
    append initrd=$kernelpath/initrd.lz noprompt boot=casper url=$seedpath/$seedfile netboot=nfs nfsroot=$nfsrootpath/$distro/$revision ro toram -
		   
EOM
}

function stock_casper_initrd_gz ()
{
kernelpath=$bootfolder/casper
mkdir -p $tftpfolder/$kernelpath
cp -uv $subfolder/casper/vmlinuz $tftpfolder/$kernelpath/
cp -uv $subfolder/casper/initrd.gz $tftpfolder/$kernelpath/
cat >> $menupath << EOM
LABEL $revision
MENU LABEL $revision
    kernel $kernelpath/vmlinuz
    append initrd=$kernelpath/initrd.gz noprompt boot=casper url=$seedpath/$seedfile netboot=nfs nfsroot=$nfsrootpath/$distro/$revision ro toram -

EOM
}

function stock_live_initrd_img ()
{
kernelpath=$bootfolder/live
mkdir -p $tftpfolder/$kernelpath
cp -uv $subfolder/live/vmlinuz $tftpfolder/$kernelpath/
cp -uv $subfolder/live/initrd.img $tftpfolder/$kernelpath/
cat >> $menupath << EOM
LABEL $revision
MENU LABEL $revision
    kernel $kernelpath/vmlinuz
    append initrd=$kernelpath/initrd.img noprompt boot=live url=$seedpath/$seedfile netboot=nfs nfsroot=$nfsrootpath/$distro/$revision ro toram -
		   
EOM
}

function generate_stock_menu ()
{
mount -t nfs4 $nfspath /mnt/
for folder in /mnt/stock/*; do
distro=$(basename "$folder")
menupath="$tftpfolder/menus/stock/$distro.conf"
echo "creating Stock - $distro menu..."
distro_title
	# PXE boot menu entry for each iso
	revisions=$( ls -r $folder )
	for revision in $revisions; do
	subfolderarray=$folder/$revision
		for subfolder in $subfolderarray; do
		revision=$(basename "$subfolder")
		bootfolder=boot/$distro/$revision
		if [ -e "$subfolder/casper/initrd.lz" ]; then
            stock_casper_initrd_lz
		elif [ -e "$subfolder/casper/initrd.gz" ]; then
            stock_casper_initrd_gz
		elif [ -e "$subfolder/live/initrd.img" ]; then
            stock_live_initrd_img
        else 
		  echo "ERROR - $distro-$revision"
		  rm $menupath  
		fi
		done
	done
done
umount -d /mnt/
}

check_for_sudo
generate_stock_menu