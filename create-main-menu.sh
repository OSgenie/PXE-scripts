#!/usr/bin/env bash
# Kirtley Wienbroer
# kirtley@osgenie.com
scriptdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $scriptdir/pxe.config

menupath="$tftp_folder/mainmenu.conf"

function check_for_sudo ()
{
  if [ $UID != 0 ]; then
          echo "You need root privileges"
          exit 2
  fi
}

function generate_main_menu_header ()
{
  cat > $menupath << EOM
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
  echo "**********************************************"
  echo "      Creating Main Menu"
  echo "**********************************************"
  for subfolder in $tftp_folder/*; do
      directory=$(dirname $subfolder)
      foldername=$(basename $subfolder)
      for conf_file in $subfolder/*; do
          fullname=$(basename $conf_file)
          extension=${fullname##*.}
          name=$(basename $conf_file .$extension)
          if [ ! -z $extension ] && [ $extension == "conf" ]; then
              conf_menu
          elif [ ! -z $fullname ] && [ $fullname == "menus" ]; then
              for menu in $subfolder/menus/*; do
                  echo $menu
                  fullname=$(basename $menu)
                  extension=${fullname##*.}
                  name=$(basename $menu .$extension)
                  if [ ! -z $extension ] && [ $extension == "conf" ]; then
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
