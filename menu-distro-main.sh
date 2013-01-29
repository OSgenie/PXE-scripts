#!/bin/bash
# Kirtley Wienbroer
# kirtley@osgenie.com
# June 24 2012
tftpfolder=/var/lib/tftpboot
menus=$( ls $tftpfolder/menus )

function check_for_sudo ()
{
if [ $UID != 0 ]; then
    echo "You need root privileges"
        exit 2
fi
}

function generate_distro_menu_header ()
{
echo $folder
menupath="$tftpfolder/menus/$folder.conf"
cat > $menupath <<EOM
MENU TITLE --== $folder Menu ==--
 
LABEL rootmenu
MENU LABEL <---- Main Menu
kernel vesamenu.c32
append mainmenu.conf
 
EOM
}

function generate_distro_submenus ()
{
echo $fullname
cat >> $menupath <<EOM
LABEL $name
MENU LABEL $name --->
kernel vesamenu.c32
append /menus/$folder/$fullname
EOM
}

function create_distro_menus ()
{
for folder in $menus; do
    generate_distro_menu_header
    for conf in $tftpfolder/menus/$folder/*; do 
        fullname=$(basename $conf)
        extension=${fullname##*.}
        name=$(basename $conf .$extension)
        if [ $extension == conf ]; then
            generate_distro_submenus
        fi
    done
done
}

rm $tftpfolder/menus/*.conf
create_distro_menus