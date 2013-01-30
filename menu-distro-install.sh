#!/bin/bash
# Kirtley Wienbroer
# kirtley@osgenie.com
nfshost=192.168.11.3
nfspath=$nfshost:/pxeboot/
nfsrootpath=$nfshost:/var/nfs/pxeboot/install
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
echo "Title"
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
echo "casper_initrd_lz"
kernelpath=$bootfolder/casper
mkdir -p $tftpfolder/$kernelpath
cp -uv $subfolder/casper/vmlinuz $tftpfolder/$kernelpath/
cp -uv $subfolder/casper/initrd.lz $tftpfolder/$kernelpath/
cat >> $menupath << EOM
LABEL $revdate
MENU LABEL $revdate
    kernel $kernelpath/vmlinuz
    append initrd=$kernelpath/initrd.lz noprompt boot=casper only-ubiquity url=$seedpath/$seedfile oem-config/enable=true netboot=nfs nfsroot=$nfsrootpath/$distro/$revision ro toram -
EOM
}

function oem_install_casper_initrd_gz ()
{
echo "casper_initrd_gz"
kernelpath=$bootfolder/casper
mkdir -p $tftpfolder/$kernelpath
cp -uv $subfolder/casper/vmlinuz $tftpfolder/$kernelpath/
cp -uv $subfolder/casper/initrd.gz $tftpfolder/$kernelpath/
cat >> $menupath << EOM
LABEL $revdate
MENU LABEL $revdate
    kernel $kernelpath/vmlinuz
    append initrd=$kernelpath/initrd.gz noprompt boot=casper only-ubiquity url=$seedpath/$seedfile oem-config/enable=true netboot=nfs nfsroot=$nfsrootpath/$distro/$revision ro toram -

EOM
}

function oem_install_install_initrd_gz ()
{
echo "install_initrd_gz"
kernelpath=$bootfolder/install
mkdir -p $tftpfolder/$kernelpath
cp -uv $subfolder/install/vmlinuz $tftpfolder/$kernelpath/
cp -uv $subfolder/install/initrd.gz $tftpfolder/$kernelpath/
cat >> $menupath << EOM
LABEL $revision
MENU LABEL $revision
    kernel $kernelpath/linux
    append initrd=$kernelpath/initrd.gz noprompt netboot=nfs url=$seedpath/$seedfile root=/dev/nfs nfsroot=$nfspath/$distro/$revision/ ip=dhcp rw

EOM
}

function oem_install_install_netboot ()
{
echo "install_netboot"
if [[ $distro == *amd64* ]]; then
    cpu=amd64
else
    cpu=i386
fi
    kernelpath=$bootfolder/install/netboot/ubuntu-installer/$cpu
mkdir -p $tftpfolder/$kernelpath
cp -uv $subfolder/install/netboot/ubuntu-installer/$cpu/linux $tftpfolder/$kernelpath/
cp -uv $subfolder/install/netboot/ubuntu-installer/$cpu/initrd.gz $tftpfolder/$kernelpath/
cat >> $menupath << EOM
LABEL $revdate
MENU LABEL $revdate
    kernel $kernelpath/linux
    append initrd=$kernelpath/initrd.gz noprompt netboot=nfs url=$seedpath/$seedfile root=/dev/nfs nfsroot=$nfspath/$distro/$revision/ ip=dhcp rw

EOM
}

function generate_install_menu ()
{
mount -t nfs4 $nfspath /mnt/
for folder in /mnt/install/*; do
    distro=$(basename "$folder")
    menupath="$tftpfolder/menus/install/$distro.conf"
    echo "creating $distro menu..."
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
    		elif [ -e "$subfolder/install/initrd.gz" ]; then
                oem_install_install_initrd_gz
            elif [ -e "$subfolder/install" ]; then
                oem_install_install_netboot
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