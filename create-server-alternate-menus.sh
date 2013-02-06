#!/usr/bin/env bash
# Kirtley Wienbroer
# kirtley@osgenie.com
nfshost=192.168.11.10
nfspath=$nfshost:/pxeboot/server
nfsrootpath=$nfshost:/var/nfs/pxeboot/server
tftpfolder=/var/lib/tftpboot
seedpath=http://192.168.11.10/stock
seedfile="https://bit.ly/uinstall"

function check_for_sudo ()
{
if [ $UID != 0 ]; then
		echo "You need root privileges"
		exit 2
fi
}

function stock_install_netboot ()
{
if [[ $distro == *amd64* ]]; then
    cpu=amd64
elif [[ $distro == *i386* ]]; then
    cpu=i386
fi
if [ -e $subfolder/install/netboot/non-pae ]; then
    kernelpath=$bootfolder/install/netboot/non-pae/ubuntu-installer/$cpu
    mkdir -p $tftpfolder/$kernelpath
    cp -uv $subfolder/install/netboot/non-pae/ubuntu-installer/$cpu/linux $tftpfolder/$kernelpath/
    cp -uv $subfolder/install/netboot/non-pae/ubuntu-installer/$cpu/initrd.gz $tftpfolder/$kernelpath/
else
    kernelpath=$bootfolder/install/netboot/ubuntu-installer/$cpu
    mkdir -p $tftpfolder/$kernelpath
    cp -uv $subfolder/install/netboot/ubuntu-installer/$cpu/linux $tftpfolder/$kernelpath/
    cp -uv $subfolder/install/netboot/ubuntu-installer/$cpu/initrd.gz $tftpfolder/$kernelpath/
fi
cat >> $menupath << EOM
LABEL $revision
MENU LABEL $revision
    kernel $kernelpath/linux
    append initrd=$kernelpath/initrd.gz noprompt netboot=nfs url=$seedfile root=/dev/nfs nfsroot=$nfspath/$distro/$revision/ ip=dhcp rw
#url=$seedpath/$distro/$revision/preseed/ubuntu-server.seed
EOM
}

function generate_server_menu ()
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
        if [ -e "$subfolder/install" ]; then
            stock_install_netboot
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
generate_server_menu