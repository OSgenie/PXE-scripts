#!/bin/bash

directories=(/var/nfs/updatediso/install /
/var/nfs/updatediso/live /
/var/nfs/pxeboot/install /
/var/nfs/pxeboot/live /
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
echo "+-------------------------------------------------------------------+"    
echo "+ `date +%c`"
echo "+-------------------------------------------------------------------+"    
find /var/lib/tftpboot/boot/*/gold -exec touch {} +
for dir in ${directories[@]}; do
    echo $dir
    find $dir/* -type f -mtime +13 -exec rm {} \;
done
}

check_for_sudo
delete_older_isos