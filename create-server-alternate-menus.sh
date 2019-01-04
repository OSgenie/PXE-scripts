#!/usr/bin/env bash
# Kirtley Wienbroer
# kirtley@osgenie.com
scriptdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $scriptdir/pxe.config

nfs_path=$nfs_server:/pxeboot
nfs_root_path=$nfs_server:/var/nfs/pxeboot/stock
seed_file=uinstall

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
        MENU LABEL <---- Server Menu
        kernel vesamenu.c32
        append menus/server.conf

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

function server_install ()
{
	if [ -f $subfolder/install/vmlinuz ]; then
		distro_kernel=vmlinuz
	elif [ -f $subfolder/install/vmlinuz.efi ]; then
		distro_kernel=vmlinuz.efi
	else
		echo "ERROR - $distro-$revision"
		echo "Kernel Not Found!!"
	fi
	if [ -e "$subfolder/install/initrd.gz" ]; then
		boot_folder=install
		distro_ram_disk=initrd.gz
		pxe_boot_stock_iso
	else
		echo "ERROR - $distro-$revision"
		echo "RAM Disk Not Found!!"
		rm $menupath
	fi
}

function generate_server_menu ()
{
	echo "**********************************************"
	echo "			Server Menus"
	echo "**********************************************"

	mount -t nfs4 $nfs_path /mnt/
	for folder in /mnt/stock/*; do
	    distro=$(basename "$folder")
	    menupath="$tftp_folder/menus/server/$distro.conf"
	    distro_title
		# PXE boot menu entry for each iso
		revisions=$( ls -r $folder )
		for revision in $revisions; do
		subfolderarray=$folder/$revision
			for subfolder in $subfolderarray; do
			revision=$(basename "$subfolder")
			bootfolder=boot/$distro/$revision
	        if [ -e "$subfolder/install/netboot" ]; then
	            echo "creating Server - $distro menu..."
	            server_install
	        else
	            rm $menupath
			fi
			done
		done
	done
	umount /mnt
}

check_for_sudo
generate_server_menu
