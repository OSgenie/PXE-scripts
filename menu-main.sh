#!/bin/bash
# Kirtley Wienbroer
# kirtley@osgenie.com
# June 24 2012
tftpfolder=/var/lib/tftpboot
menupath="$tftpfolder/mainmenu.conf"

function check_for_sudo ()
{
if [ $UID != 0 ]; then
		echo "You need root privileges"
		exit 2
fi
}

function create_menu_header ()
{
cat > $menupath <<'EOM'
MENU TITLE --== Main Menu ==--
DEFAULT vesamenu.c32
TIMEOUT 200 #this is optional - will start the default after 20 seconds
ONTIMEOUT BootLocal
PROMPT 0
#
LABEL kirtley-workstation
MENU DEFAULT
MENU LABEL Kirtley Workstation
KERNEL pxe-kw/vmlinuz-3.2.0-29-generic-pae
APPEND root=/dev/nfs initrd=pxe-kw/initrd.img-3.2.0-29-generic-pae nfsroot=192.168.11.88:/var/nfs/pxe-kw,rw ip=dhcp rw
#
LABEL BootLocal
MENU LABEL Local Boot
localboot 0
#
EOM
}

function add_submenus ()
{
for subfolder in $tftpfolder/*; do
directory=$(dirname $subfolder)
foldername=$(basename "$subfolder")
	for conf in $subfolder/*; do 
	fullname=$(basename $conf)
	extension=${fullname##*.}
	name=$(basename $conf .$extension)
	if [ $extension == conf ]; then
		cat >> $menupath << 'EOM'
		LABEL $name
		MENU LABEL $name --->
		kernel vesamenu.c32
		append /$foldername/$fullname
		#
EOM
	elif [ $fullname == menus ]; then
		for menu in $subfolder/menus/*; do 
		echo $menu
		fullname=$(basename $menu)
		extension=${fullname##*.}
		name=$(basename $menu .$extension)
		if [ $extension == conf ]; then
			cat >> $menupath << 'EOM'
			LABEL $name
			MENU LABEL $name --->
			kernel vesamenu.c32
			append $foldername/menus/$fullname
			#
EOM
		fi
		done			
	fi
	done
done
}

check_for_sudo
create_menu_header
add_submenus