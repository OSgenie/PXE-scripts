#!/usr/bin/env bash
# Kirtley Wienbroer
# kirtley@osgenie.com
scriptdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $scriptdir/pxe.config

function check_for_sudo ()
{
  if [ $UID != 0 ]; then
      echo "You need root privileges"
          exit 2
  fi
}

function generate_distro_menu_header ()
{
  echo "**********************************************"
  echo "        Creating Master $folder Menu"
  echo "**********************************************"
  menupath="$tftp_folder/menus/$folder.conf"
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
  menus=$( ls $tftp_folder/menus )
  for folder in $menus; do
      generate_distro_menu_header
      for conf_file in $tftp_folder/menus/$folder/*; do
          fullname=$(basename $conf_file)
          extension=${fullname##*.}
          name=$(basename $conf_file .$extension)
          if [ ! -z $extension ] && [ $extension == "conf" ]; then
              generate_distro_submenus
          fi
      done
  done
}

check_for_sudo
refresh_distro_menus
