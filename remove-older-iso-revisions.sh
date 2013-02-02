#!/bin/bash

directories=(
/var/nfs/updatediso/install
/var/nfs/updatediso/live
/var/nfs/pxeboot/install
/var/nfs/pxeboot/live
/var/lib/tftpboot/boot
)

function check_for_sudo ()
{
if [ $UID != 0 ]; then
        echo "You need root privileges"
        exit 2
fi
}

function delete_older_isos ()
{
find /var/lib/tftpboot/boot/*/gold -exec touch {} +
for dir in $directories; do
    find $dir/* -mtime +2 #-delete
done
}

check_for_sudo
delete_older_isos