#!/bin/bash
# Kirtley Wienbroer
# kirtley@osgenie.com

nfshost=192.168.11.3
nfspath=$nfshost:/pxeboot
nfsrootpath=$nfshost:/var/nfs/pxeboot
tftpfolder=/var/lib/tftpboot
seedpath=http://192.168.11.10/preseed
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
#
LABEL rootmenu
MENU LABEL <---- Live Menu
kernel vesamenu.c32
append menus/live.conf
EOM
}

function casper_initrd_lz ()
{
kernelpath=$bootfolder/casper
mkdir -p $tftpfolder/$kernelpath
cp -uv $subfolder/casper/vmlinuz $tftpfolder/$kernelpath/
cp -uv $subfolder/casper/initrd.lz $tftpfolder/$kernelpath/
cat >> $menupath << EOM
LABEL $revdate >> $menupath
MENU LABEL $revdate >> $menupath
    kernel $kernelpath/vmlinuz
    append initrd=$kernelpath/initrd.lz noprompt boot=casper url=$seedpath/$seedfile netboot=nfs nfsroot=$nfsrootpath/$distro/$revision ro toram -
EOM
}

function casper_initrd_gz ()
{
kernelpath=$bootfolder/casper
mkdir -p $tftpfolder/$kernelpath
cp -uv $subfolder/casper/vmlinuz $tftpfolder/$kernelpath/
cp -uv $subfolder/casper/initrd.gz $tftpfolder/$kernelpath/
cat >> $menupath << EOM
LABEL $revdate >> $menupath
MENU LABEL $revdate >> $menupath
    kernel $kernelpath/vmlinuz
    append initrd=$kernelpath/initrd.gz noprompt boot=casper url=$seedpath/$seedfile netboot=nfs nfsroot=$nfsrootpath/$distro/$revision ro toram -
EOM
}

function generate_live_menu ()
{
mount -t nfs4 $nfspath /mnt/
for folder in /mnt/live/*; do
    distro=$(basename "$folder")
    menupath="$tftpfolder/menus/live/$distro.conf"
    echo "creating $distro menu..."
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
            bootfolder=isodistro/$distro/$revision
            if [ -e "$subfolder/casper/initrd.lz" ]; then
                casper_initrd_lz
            elif [ -e "$subfolder/casper/initrd.gz" ]; then
                casper_initrd_gz
            else 
                echo " not a live cd"
            rm $menupath  
            fi
        done
    done
done
umount /mnt/
}

check_for_sudo
generate_live_menu