#!/usr/bin/env bash
# Kirtley Wienbroer
# kirtley@osgenie.com
tftpfolder=/var/lib/tftpboot

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

function refresh_distro_menus ()
{
rm $tftpfolder/menus/*.conf
menus=$( ls $tftpfolder/menus )
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

check_for_sudo
refresh_distro_menus