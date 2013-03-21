#!/usr/bin/env bash
# Kirtley Wienbroer
# kirtley@osgenie.com
torrent_downloads=$(find /var/nfs/transmission/complete/* -maxdepth 2 -type f -name *.iso)
wget_downloads=$(find /var/nfs/iso/* -maxdepth 2 -type f -name *.iso)
downloaded_isos=("${torrent_downloads[@]}" "${wget_downloads[@]}")
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
for iso in $downloaded_isos; do
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