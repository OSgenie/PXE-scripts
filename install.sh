#!/usr/bin/env bash
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
http_preseed_root=/var/nfs/pxeboot/preseed
binary_dir=/usr/local/bin
log_dir=/var/log

function check_for_sudo ()
{
	if [ $UID != 0 ]; then
			echo "You need root privileges"
			exit 2
	fi
}

function install_config_source_local_bin ()
{
	echo "server_ip=$(/sbin/ifconfig eth0 | grep 'inet addr' | cut -d: -f2 | awk '{print $1}')" | tee $script_dir/pxe.config
	echo "tftp_folder=/var/lib/tftpboot" | tee -a $script_dir/pxe.config
	echo "nfs_server=\$server_ip" | tee -a $script_dir/pxe.config
	echo "seed_path=http://\$server_ip/preseed" | tee -a $script_dir/pxe.config
	install $script_dir/pxe.config $binary_dir/pxe.config
}

function install_scripts_local_bin ()
{
	install -d $binary_dir
	install $script_dir/build-pxemenus.sh $binary_dir/build-pxemenus
	install $script_dir/create-install-menus.sh $binary_dir/create-install-menus
	install $script_dir/create-live-menus.sh $binary_dir/create-live-menus
	install $script_dir/create-submenus.sh $binary_dir/create-submenus
	install $script_dir/create-stock-menus.sh $binary_dir/create-stock-menus
	install $script_dir/create-server-alternate-menus.sh $binary_dir/create-server-alternate-menus
	install $script_dir/create-netboot-menus.sh $binary_dir/create-netboot-menus
#install $script_dir/create-utility-menu.sh $binary_dir/create-utility-menu
	install $script_dir/create-main-menu.sh $binary_dir/create-main-menu
	install $script_dir/nfs-extract-iso.sh $binary_dir/extract-isos
	install $script_dir/remove-older-iso-revisions.sh $binary_dir/remove-older-iso-revisions
	install $script_dir/generate-update-lists.sh $binary_dir/generate-update-lists
	install $script_dir/get-torrents.sh $binary_dir/get-torrents
	cp -r $script_dir/torrent.configs $binary_dir/
}

function configure_crontab ()
{
	echo "# m h  dom mon dow   command" | crontab -
	crontab -l | { cat; echo "@hourly $binary_dir/extract-isos  > $log_dir/extract-isos.log"; } | crontab -
	crontab -l | { cat; echo "@daily $binary_dir/build-pxemenus  > $log_dir/build-pxemenus.log"; } | crontab -
	crontab -l | { cat; echo "@weekly $binary_dir/remove-older-iso-revisions  > $log_dir/remove-older-isos.log"; } | crontab -
	crontab -l | { cat; echo "@weekly $binary_dir/get-torrents  > $log_dir/get-torrents.log"; } | crontab -
}

function copy_preseeds ()
{
	cp -uv $script_dir/preseed/* $http_preseed_root/
}

check_for_sudo
install_config_source_local_bin
install_scripts_local_bin
copy_preseeds
configure_crontab
