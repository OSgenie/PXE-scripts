#!/bin/bash
torrentdownload=/var/nfs/transmission/complete
wgetdownload=/var/nfs/iso
isofolder=/var/nfs/updatediso
pxeshare=/var/nfs/pxeboot

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
            sudo mount -o ro,loop $iso /mnt/
            sudo mkdir -p $pxefolder
            sudo cp -ru /mnt/* $pxefolder
            sudo cp -ru /mnt/.disk $pxefolder
            sudo umount /mnt/
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
        	   sudo mount -o ro,loop $iso /mnt/
        	   sudo mkdir -p $pxefolder
        	   sudo cp -ru /mnt/* $pxefolder
        	   sudo cp -ru /mnt/.disk $pxefolder
        	   sudo umount /mnt/
        	else
        	   echo "$pxefolder exists!"
        	fi
        fi
    done
done
}

extract_stock_iso
extract_modified_iso