#!/bin/bash
# Kirtley Wienbroer
# kirtley@osgenie.com
# June 24 2012
tftpfolder=/var/lib/tftpboot

function check_for_sudo ()
{
if [ $UID != 0 ]; then
    echo "You need root privileges"
        exit 2
fi
}

function create_distro_menus ()
{
menusarray=$( ls $tftpfolder/menus )
for folder in $menusarray; do
    echo $folder
    menupath="$tftpfolder/menus/$folder.conf"
    cat > $menupath <<EOM
    MENU TITLE --== $folder Menu ==--
    #
    LABEL rootmenu
       MENU LABEL <---- Main Menu
       kernel vesamenu.c32
        append mainmenu.conf
    #
EOM
    for conf in $tftpfolder/menus/$folder/*; do 
        fullname=$(basename $conf)
        extension=${fullname##*.}
        name=$(basename $conf .$extension)
        if [ $extension == conf ]; then
            echo $fullname
            cat >> $menupath <<EOM
            LABEL $name
                MENU LABEL $name --->
               kernel vesamenu.c32
               append /menus/$folder/$fullname
EOM
        fi
    done
done
}

rm $tftpfolder/menus/*.conf
create_distro_menus