#!/bin/bash

directories=(/var/nfs/pxeboot/install \
/var/nfs/pxeboot/live \
/var/lib/tftpboot/boot
)

files=(/var/nfs/updatediso/install \
/var/nfs/updatediso/install/md5 \
/var/nfs/updatediso/live \
/var/nfs/updatediso/live/md5
)

function check_for_sudo ()
{
if [ $UID != 0 ]; then
        echo "You need root privileges"
        exit 2
fi
}

function delete_older_media ()
{
echo "+-------------------------------------------------------------------+"    
echo "+ `date +%c`"
echo "+-------------------------------------------------------------------+"    
for dir in ${directories[@]}; do
    find $dir/* -mtime +15 -exec rm -v {} \;
done
find /var/lib/tftpboot/boot/*/gold -exec touch {} +
for file in ${files[@]}; do
    find $file/* -type f -mtime +15 -exec rm -v {} \;
done
}

check_for_sudo
delete_older_media