#!/usr/bin/env bash
scriptdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

function check_for_sudo ()
{
if [ $UID != 0 ]; then
		echo "You need root privileges"
		exit 2
fi
}

function install_scripts_local_bin ()
{
install $scriptdir/build-pxemenus.sh /usr/local/bin/build-pxemenus
install $scriptdir/create-install-menus.sh /usr/local/bin/create-install-menus.sh
install $scriptdir/create-live-menus.sh /usr/local/bin/create-live-menus.sh
install $scriptdir/create-submenus.sh /usr/local/bin/create-submenus.sh
install $scriptdir/create-stock-menus.sh /usr/local/bin/create-stock-menus.sh
install $scriptdir/create-main-menu.sh /usr/local/bin/create-main-menu.sh
install $scriptdir/create-server-alternate-menus.sh /usr/local/bin/create-server-alternate-menus.sh
#install $scriptdir/create-utility-menu.sh /usr/local/bin/create-utility-menu.sh
install $scriptdir/nfs-extract-iso.sh /usr/local/bin/extract-isos
install $scriptdir/remove-older-iso-revisions.sh /usr/local/bin/remove-older-iso-revisions
}

function configure_crontab ()
{
echo "# m h  dom mon dow   command" | crontab -
crontab -l | { cat; echo "*/10 * * * * /usr/local/bin/build-pxemenus  > /var/log/build-pxemenus.log"; } | crontab -
crontab -l | { cat; echo "2-52/10 * * * * /usr/local/bin/extract-isos  > /var/log/extract-isos.log"; } | crontab -
crontab -l | { cat; echo "@weekly /usr/local/bin/remove-older-iso-revisions  >> /var/log/remove-older-isos.log"; } | crontab -
}

check_for_sudo
install_scripts_local_bin
configure_crontab