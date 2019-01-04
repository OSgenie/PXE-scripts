#!/usr/bin/env bash
# Kirtley Wienbroer
# kirtley@osgenie.com
scriptdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $scriptdir/pxe.config

nfs_path=$nfs_server:/pxeboot
nfs_root_path=$nfs_server:/pxeboot/stock
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

function pxe_boot_stock_iso ()
{
kernelpath=$tftp_boot_folder/$boot_folder
mkdir -p $tftp_folder/$kernelpath
cp -uv $subfolder/$boot_folder/$distro_kernel $tftp_folder/$kernelpath/
cp -uv $subfolder/$boot_folder/$distro_ram_disk $tftp_folder/$kernelpath/
cat >> $menupath << EOM
LABEL $revision
MENU LABEL $revision
    kernel $kernelpath/$distro_kernel
    append initrd=$kernelpath/$distro_ram_disk noprompt boot=$boot_folder url=$seed_path/$seed_file netboot=nfs nfsroot=$nfs_root_path/$distro/$revision ro toram -

EOM
}

function generate_stock_menu ()
{
	echo "**********************************************"
	echo "			Stock Menus"
	echo "**********************************************"

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
			tftp_boot_folder=boot/$distro/$revision
			if [ -e $subfolder/casper ]; then
					boot_folder=casper
						if [ -f $subfolder/casper/vmlinuz ]; then
								distro_kernel=vmlinuz
						elif [ -f $subfolder/casper/vmlinuz.efi ]; then
								distro_kernel=vmlinuz.efi
						else
							echo "ERROR - $distro-$revision"
							echo "Kernel Not Found!!"
						fi
						if [ -e $subfolder/casper/initrd.lz ]; then
								distro_ram_disk=initrd.lz
						elif [ -e $subfolder/casper/initrd.gz ]; then
								distro_ram_disk=initrd.gz
						elif [ -e $subfolder/casper/initrd ]; then
								distro_ram_disk=initrd
						fi
			elif [ -e $subfolder/live ]; then
					boot_folder=live
						if [ -e $subfolder/live/initrd.img ]; then
						distro_ram_disk=initrd.img
						fi
						if [ -f $subfolder/live/vmlinuz ]; then
							distro_kernel=vmlinuz
						elif [ -f $subfolder/live/vmlinuz.efi ]; then
							distro_kernel=vmlinuz.efi
						else
							echo "ERROR - $distro-$revision"
							echo "Kernel Not Found!!"
						fi
			elif [ -e $subfolder/install ]; then
					boot_folder=install
						if [ -e $subfolder/install/initrd.gz ]; then
							distro_ram_disk=initrd.gz
						fi
						if [ -f $subfolder/install/vmlinuz ]; then
							distro_kernel=vmlinuz
						fi
			fi
			if [ -z $distro_ram_disk ]; then
				echo "ERROR - $distro-$revision"
				echo "RAM Disk Not Found!!"
				rm $menupath
			elif [ -z $distro_kernel ]; then
				echo "ERROR - $distro-$revision"
				echo "Kernel Not Found!!"
				rm $menupath
			else
				pxe_boot_stock_iso
			fi
			done
		done
	done
	umount -d /mnt/
}

check_for_sudo
generate_stock_menu
