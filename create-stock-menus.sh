#!/usr/bin/env bash
# Kirtley Wienbroer
# kirtley@osgenie.com
source pxe.config

nfs_path=$nfs_server:/pxeboot/stock
nfs_root_path=$nfs_server:/var/nfs/pxeboot/stock
seed_file="ubuntu.seed"

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
mkdir -p $tftp_folder/$kernelpath
cp -uv $subfolder/casper/vmlinuz $tftp_folder/$kernelpath/
cp -uv $subfolder/casper/initrd.lz $tftp_folder/$kernelpath/
cat >> $menupath << EOM
LABEL $revision
MENU LABEL $revision
    kernel $kernelpath/vmlinuz
    append initrd=$kernelpath/initrd.lz noprompt boot=casper url=$seed_path/$seed_file netboot=nfs nfsroot=$nfs_root_path/$distro/$revision ro toram -

EOM
}

function stock_casper_initrd_gz ()
{
kernelpath=$bootfolder/casper
mkdir -p $tftp_folder/$kernelpath
cp -uv $subfolder/casper/vmlinuz $tftp_folder/$kernelpath/
cp -uv $subfolder/casper/initrd.gz $tftp_folder/$kernelpath/
cat >> $menupath << EOM
LABEL $revision
MENU LABEL $revision
    kernel $kernelpath/vmlinuz
    append initrd=$kernelpath/initrd.gz noprompt boot=casper url=$seed_path/$seed_file netboot=nfs nfsroot=$nfs_root_path/$distro/$revision ro toram -

EOM
}

function stock_live_initrd_img ()
{
kernelpath=$bootfolder/live
mkdir -p $tftp_folder/$kernelpath
cp -uv $subfolder/live/vmlinuz $tftp_folder/$kernelpath/
cp -uv $subfolder/live/initrd.img $tftp_folder/$kernelpath/
cat >> $menupath << EOM
LABEL $revision
MENU LABEL $revision
    kernel $kernelpath/vmlinuz
    append initrd=$kernelpath/initrd.img noprompt boot=live url=$seed_path/$seed_file netboot=nfs nfsroot=$nfs_root_path/$distro/$revision ro toram -

EOM
}

function generate_stock_menu ()
{
mount -t nfs4 $nfs_path /mnt/
for folder in /mnt/stock/*; do
distro=$(basename "$folder")
menupath="$tftp_folder/menus/stock/$distro.conf"
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
