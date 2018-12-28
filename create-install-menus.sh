#!/usr/bin/env bash
# Kirtley Wienbroer
# kirtley@osgenie.com
source pxe.config

nfs_path=$nfs_server:/pxeboot/install
nfs_root_path=$nfs_server:/var/nfs/pxeboot/install
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
        MENU LABEL <---- Install Menu
        kernel vesamenu.c32
        append menus/install.conf

EOM
}

function oem_install_casper_initrd_lz ()
{
kernelpath=$bootfolder/casper
mkdir -p $tftp_folder/$kernelpath
cp -uv $subfolder/casper/vmlinuz $tftp_folder/$kernelpath/
cp -uv $subfolder/casper/initrd.lz $tftp_folder/$kernelpath/
cat >> $menupath << EOM
LABEL $revdate
MENU LABEL $revdate
    kernel $kernelpath/vmlinuz
    append initrd=$kernelpath/initrd.lz noprompt boot=casper only-ubiquity url=$seed_path/$seed_file oem-config/enable=true netboot=nfs nfsroot=$nfs_root_path/$distro/$revision ro toram -
EOM
}

function oem_install_casper_initrd_gz ()
{
kernelpath=$bootfolder/casper
mkdir -p $tftp_folder/$kernelpath
cp -uv $subfolder/casper/vmlinuz $tftp_folder/$kernelpath/
cp -uv $subfolder/casper/initrd.gz $tftp_folder/$kernelpath/
cat >> $menupath << EOM
LABEL $revdate
MENU LABEL $revdate
    kernel $kernelpath/vmlinuz
    append initrd=$kernelpath/initrd.gz noprompt boot=casper only-ubiquity url=$seed_path/$seed_file oem-config/enable=true netboot=nfs nfsroot=$nfs_root_path/$distro/$revision ro toram -

EOM
}

function generate_install_menu ()
{
mount -t nfs4 $nfs_path /mnt/
for folder in /mnt/install/*; do
    distro=$(basename "$folder")
    menupath="$tftp_folder/menus/install/$distro.conf"
    echo "creating Install - $distro menu..."
    distro_title
    revisions=$( ls -r $folder )
	# PXE boot menu entry for each iso
	for revision in $revisions; do
    	if [ ! "$revision" = "gold" ]; then
    	   revdate=$(date --rfc-3339=seconds -d @$revision)
    	else
    	   revdate=$revision
    	fi
    	subfolderarray=$folder/$revision
		for subfolder in $subfolderarray; do
    		revision=$(basename "$subfolder")
    		bootfolder=boot/$distro/$revision
    		if [ -e "$subfolder/casper/initrd.lz" ]; then
                oem_install_casper_initrd_lz
    		elif [ -e "$subfolder/casper/initrd.gz" ]; then
                oem_install_casper_initrd_gz
    		else
    		  echo "ERROR - $distro-$revision"
    		fi
		done
	done
done
umount /mnt
}

check_for_sudo
generate_install_menu
