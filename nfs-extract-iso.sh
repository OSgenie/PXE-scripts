#!/bin/bash
torrentdownload=/var/nfs/transmission/complete
wgetdownload=/var/nfs/iso
isofolder=/var/nfs/updatediso
pxeshare=/var/nfs/pxeboot

function check_for_sudo ()
{
if [ $UID != 0 ]; then
		echo "You need root privileges"
		exit 2
fi
}

function extract_stock_iso ()
{
for folder in $torrentdownload $wgetdownload; do
    for iso in $folder/*; do
    fullname=$(basename "$iso")
    extension=${fullname##*.}
    distro=$(basename $iso .$extension)
    pxefolder=$pxeshare/stock/$distro/gold
    if [ $extension == iso ]; then
        if [ ! -e $pxefolder ]; then
            echo "COPY Stock - $fullname"
            mount -o ro,loop $iso /mnt/
            mkdir -p $pxefolder
            cp -ru /mnt/* $pxefolder
            cp -ru /mnt/.disk $pxefolder
            umount /mnt/
        else
            echo "$pxefolder exists!"
        fi
    fi
    done
done
}

function extract_modified_iso ()
{
for folder in $isofolder/*; do
    for iso in $folder/*; do
        type=$(basename $folder)    
        fullname=$(basename "$iso")
        extension=${fullname##*.}
        name=$(basename $iso .$extension)
        version=${name##*-}
        distro=$(basename $name -$version)
        pxefolder=$pxeshare/$type/$distro/$version
        if [ $extension == iso ];then
        	if [ ! -e $pxefolder ]; then
        	   echo "COPY $name - $type"
        	   mount -o ro,loop $iso /mnt/
        	   mkdir -p $pxefolder
        	   cp -ru /mnt/* $pxefolder
        	   cp -ru /mnt/.disk $pxefolder
        	   umount /mnt/
        	else
        	   echo "$pxefolder exists!"
        	fi
        fi
    done
done
}

check_for_sudo
extract_stock_iso
extract_modified_iso