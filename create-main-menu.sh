#!/usr/bin/env bash
# Kirtley Wienbroer
# kirtley@osgenie.com
tftpfolder=/var/lib/tftpboot
menupath="$tftpfolder/mainmenu.conf"
nfs_server=192.168.11.10

function check_for_sudo ()
{
if [ $UID != 0 ]; then
        echo "You need root privileges"
        exit 2
fi
}

function generate_main_menu_header ()
{
cat > $menupath <<EOM
DEFAULT vesamenu.c32
PROMPT 0
TIMEOUT 200 #this is optional - will start the default after 20 seconds
ONTIMEOUT local

MENU TITLE --== Main Menu ==--

LABEL workstation
MENU DEFAULT
MENU LABEL PXE Workstation
KERNEL pxe-kw/vmlinuz-3.2.0-35-generic-pae
APPEND initrd=pxe-kw/initrd.img-3.2.0-35-generic-pae root=/dev/nfs nfsroot=$nfs_server:/var/nfs/pxe-kw-4,rw ip=dhcp rw

LABEL local
MENU LABEL Boot Local Hard Drive
localboot 0

EOM
}

function conf_menu ()
{
cat >> $menupath << EOM
LABEL $name
MENU LABEL $name --->
kernel vesamenu.c32
append /$foldername/$fullname
#
EOM
}

function conf_submenus ()
{
cat >> $menupath << EOM
LABEL $name
MENU LABEL $name --->
kernel vesamenu.c32
append $foldername/menus/$fullname
#
EOM
}

function generate_conf_menus ()
{
echo "Creating Main Menu"
for subfolder in $tftpfolder/*; do
    directory=$(dirname $subfolder)
    foldername=$(basename "$subfolder")
    for conf in $subfolder/*; do 
        fullname=$(basename $conf)
        extension=${fullname##*.}
        name=$(basename $conf .$extension)
        if [ $extension == conf ]; then
            conf_menu
        elif [ $fullname == menus ]; then
            for menu in $subfolder/menus/*; do 
                echo $menu
                fullname=$(basename $menu)
                extension=${fullname##*.}
                name=$(basename $menu .$extension)
                if [ $extension == conf ]; then
                conf_submenus
                fi
            done            
        fi
    done
done
}

check_for_sudo
generate_main_menu_header
generate_conf_menus