#!/bin/bash
# Kirtley Wienbroer
# kirtley@osgenie.com
nfshost=192.168.11.88
nfspath=$nfshost:/pxeboot/stock
nfsrootpath=$nfshost:/var/nfs/pxeboot/stock
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
LABEL rootmenu
MENU LABEL <---- Stock Menu
    kernel vesamenu.c32
    append menus/stock.conf

EOM
}

function casper_init_lz ()
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

function casper_initrd_gz ()
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

function install_initrd_gz ()
{
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

function install_netboot ()
{
if [[ $distro == *amd64* ]]; then
    cpu=amd64
elif [[ $distro == *i386* ]]; then
    cpu=i386
else
    break
fi
kernelpath=$bootfolder/install/netboot/ubuntu-installer/$cpu
mkdir -p $tftpfolder/$kernelpath
cp -uv $subfolder/install/netboot/ubuntu-installer/$cpu/linux $tftpfolder/$kernelpath/
cp -uv $subfolder/install/netboot/ubuntu-installer/$cpu/initrd.gz $tftpfolder/$kernelpath/
cat >> $menupath << EOM
LABEL $revision
MENU LABEL $revision
    kernel $kernelpath/linux
    append initrd=$kernelpath/initrd.gz noprompt netboot=nfs url=$seedpath/$seedfile root=/dev/nfs nfsroot=$nfspath/$distro/$revision/ ip=dhcp rw

EOM
}

function generate_stock_menu ()
{
mount -t nfs4 $nfspath /mnt/pxeboot
for folder in /mnt/stock/*; do
distro=$(basename "$folder")
menupath="$tftpfolder/menus/stock/$distro.conf"
echo "creating $distro menu..."
distro_title
	# PXE boot menu entry for each iso
	revisions=$( ls -r $folder )
	for revision in $revisions; do
	subfolderarray=$folder/$revision
		for subfolder in $subfolderarray; do
		revision=$(basename "$subfolder")
		bootfolder=isodistro/stock/$distro/$revision
		if [ -e "$subfolder/casper/initrd.lz" ]; then
            casper_init_lz
    		break
		elif [ -e "$subfolder/casper/initrd.gz" ]; then
            casper_initrd_gz
            break
		elif [ -e "$subfolder/install/initrd.gz" ]; then
            install_initrd_gz
            break
        elif [ -e "$subfolder/install" ]; then
            install_netboot
            break
		else 
		  echo "ERROR - $distro-$revision"
		  rm $menupath  
		fi
		done
	done
done
umount /mnt
}

check_for_sudo
generate_stock_menu