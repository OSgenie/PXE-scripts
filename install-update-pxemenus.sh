#!/bin/bash

function install_scripts_local_bin ()
{
sudo install build-pxemenus.sh /usr/local/bin/build-pxemenus
sudo install create-install-menus.sh /usr/local/bin/create-install-menus.sh
sudo install create-live-menus.sh /usr/local/bin/create-live-menus.sh
sudo install create-submenus.sh /usr/local/bin/create-submenus.sh
sudo install create-stock-menus.sh /usr/local/bin/create-stock-menus.sh
sudo install create-main-menu.sh /usr/local/bin/create-main-menu.sh
#sudo install create-utility-menu.sh /usr/local/bin/create-utility-menu.sh
sudo install nfs-extract-iso.sh /usr/local/bin/extract-isos
}

function configure_crontab ()
{
echo "# m h  dom mon dow   command" | sudo crontab -
sudo crontab -l | { cat; echo "*/10 * * * * /usr/local/bin/build-pxemenus"; } | sudo crontab -
sudo crontab -l | { cat; echo "2-52/10 * * * * /usr/local/bin/extract-isos"; } | sudo crontab -
}

install_scripts_local_bin
configure_crontab