#!/bin/bash

function check_for_sudo ()
{
if [ $UID != 0 ]; then
		echo "You need root privileges"
		exit 2
fi
}

function install_scripts_local_bin ()
{
install build-pxemenus.sh /usr/local/bin/build-pxemenus
install create-install-menus.sh /usr/local/bin/create-install-menus.sh
install create-live-menus.sh /usr/local/bin/create-live-menus.sh
install create-submenus.sh /usr/local/bin/create-submenus.sh
install create-stock-menus.sh /usr/local/bin/create-stock-menus.sh
install create-main-menu.sh /usr/local/bin/create-main-menu.sh
#install create-utility-menu.sh /usr/local/bin/create-utility-menu.sh
install nfs-extract-iso.sh /usr/local/bin/extract-isos
}

function configure_crontab ()
{
echo "# m h  dom mon dow   command" | crontab -
crontab -l | { cat; echo "*/10 * * * * /usr/local/bin/build-pxemenus"; } | crontab -
crontab -l | { cat; echo "2-52/10 * * * * /usr/local/bin/extract-isos"; } | crontab -
}

check_for_sudo
install_scripts_local_bin
configure_crontab