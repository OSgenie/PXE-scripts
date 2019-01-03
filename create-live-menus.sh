#!/usr/bin/env bash
# Kirtley Wienbroer
# kirtley@osgenie.com
scriptdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $scriptdir/pxe.config

nfs_path=$nfs_server:/pxeboot
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
#
LABEL rootmenu
MENU LABEL <---- Live Menu
kernel vesamenu.c32
append menus/live.conf
EOM
}

function live_casper ()
{
kernelpath=$bootfolder/casper

if [ -f $subfolder/casper/vmlinuz ]; then
	distro_kernel=vmlinuz
elif [ -f $subfolder/casper/vmlinuz.efi ]; then
	distro_kernel=vmlinuz.efi
else
	echo " not a live iso (a)"
	break
fi

if [ -f $subfolder/casper/initrd.lz ]; then
	distro_ram_disk=initrd.lz
elif [ -f $subfolder/casper/initrd ]; then
	distro_ram_disk=initrd
else
	echo " not a live iso (b)"
	break
fi

mkdir -p $tftp_folder/$kernelpath
cp -uv $subfolder/casper/$distro_kernel $tftp_folder/$kernelpath/
cp -uv $subfolder/casper/$distro_ram_disk $tftp_folder/$kernelpath/
cat >> $menupath << EOM
LABEL $revdate
MENU LABEL $revdate
    kernel $kernelpath/$distro_kernel
    append initrd=$kernelpath/$distro_ram_disk noprompt boot=casper url=$seed_path/$seed_file netboot=nfs nfsroot=$nfs_root_path/$distro/$revision ro toram -
EOM
}

function generate_live_menu ()
{
mount -t nfs4 $nfs_path /mnt/
for folder in /mnt/stock/*; do
    distro=$(basename "$folder")
    menupath="$tftp_folder/menus/live/$distro.conf"
    echo "creating Live - $distro menu..."
    distro_title
    # PXE boot menu entry for each iso
    revisions=$( ls -r $folder )
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
            if [ -d "$subfolder/casper/" ]; then
                live_casper
            else
                echo " not a live iso (c)"
            		rm $menupath
            fi
        done
    done
done
umount /mnt/
}

check_for_sudo
generate_live_menu
