#!/usr/bin/env bash
# Kirtley Wienbroer
# kirtley@osgenie.com
scriptdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $scriptdir/pxe.config

nfs_path=$nfs_server:/pxeboot
nfs_root_path=$nfs_server:/pxeboot/stock
seed_path=http://\$server_ip/preseed
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
        MENU LABEL <---- Netboot Menu
        kernel vesamenu.c32
        append menus/netboot.conf

EOM
}

function pxe_install_netboot ()
{
if [[ $distro == *amd64* ]]; then
    cpu=amd64
elif [[ $distro == *i386* ]]; then
    cpu=i386
fi
if [ -e $subfolder/install/netboot/non-pae ]; then
    kernelpath=$bootfolder/install/netboot/non-pae/ubuntu-installer/$cpu
    mkdir -p $tftp_folder/$kernelpath
    cp -uv $subfolder/install/netboot/non-pae/ubuntu-installer/$cpu/linux $tftp_folder/$kernelpath/
    cp -uv $subfolder/install/netboot/non-pae/ubuntu-installer/$cpu/initrd.gz $tftp_folder/$kernelpath/
else
    kernelpath=$bootfolder/install/netboot/ubuntu-installer/$cpu
    mkdir -p $tftp_folder/$kernelpath
    cp -uv $subfolder/install/netboot/ubuntu-installer/$cpu/linux $tftp_folder/$kernelpath/
    cp -uv $subfolder/install/netboot/ubuntu-installer/$cpu/initrd.gz $tftp_folder/$kernelpath/
fi
cat >> $menupath << EOM
LABEL $revision
MENU LABEL $revision
    kernel $kernelpath/linux
    append initrd=$kernelpath/initrd.gz priority=critical locale=en_US url=$seed_path/$seed_file netboot=nfs root=/dev/nfs nfsroot=$nfs_path/$distro/$revision/ ip=dhcp rw
#url=$seed_path/$distro/$revision/preseed/ubuntu-server.seed
EOM
}

function generate_netboot_menu ()
{
	echo "**********************************************"
	echo "			Netboot Menus"
	echo "**********************************************"

	mount -t nfs4 $nfs_path /mnt/
	for folder in /mnt/stock/*; do
	    distro=$(basename "$folder")
	    menupath="$tftp_folder/menus/netboot/$distro.conf"
	    distro_title
		# PXE boot menu entry for each iso
		revisions=$( ls -r $folder )
		for revision in $revisions; do
		subfolderarray=$folder/$revision
			for subfolder in $subfolderarray; do
			revision=$(basename "$subfolder")
			bootfolder=boot/$distro/$revision
	        if [ -e "$subfolder/install/netboot" ]; then
	            echo "creating Netboot - $distro menu..."
	            pxe_install_netboot
	        else
	            rm $menupath
			fi
			done
		done
	done
	umount /mnt
}

check_for_sudo
generate_netboot_menu
