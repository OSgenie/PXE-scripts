#!/usr/bin/env bash
application_name=iso2pxe

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
http_preseed_root=/var/nfs/pxeboot/preseed
binary_dir=/usr/local/bin
log_dir=/var/log
application_dir=$binary_dir/$application_name
application_log=$log_dir/$application_name

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
	install $script_dir/pxe.config $application_dir/pxe.config
}
function install_scripts_local_bin ()
{
	install -d $application_dir
	install $script_dir/build-pxemenus.sh $application_dir/build-pxemenus
	install $script_dir/create-install-menus.sh $application_dir/create-install-menus
	install $script_dir/create-live-menus.sh $application_dir/create-live-menus
	install $script_dir/create-submenus.sh $application_dir/create-submenus
	install $script_dir/create-stock-menus.sh $application_dir/create-stock-menus
	install $script_dir/create-main-menu.sh $application_dir/create-main-menu
	install $script_dir/create-server-alternate-menus.sh $application_dir/create-server-alternate-menus
	#install $script_dir/create-utility-menu.sh $application_dir/create-utility-menu
	install $script_dir/nfs-extract-iso.sh $application_dir/extract-isos
	install $script_dir/remove-older-iso-revisions.sh $application_dir/remove-older-iso-revisions
	install $script_dir/generate-update-lists.sh $application_dir/generate-update-lists
	install $script_dir/get-torrents.sh $application_dir/get-torrents
	cp -r $script_dir/torrent.configs $application_dir/
}

function configure_crontab ()
{
	mkdir -p $application_log
	echo "# m h  dom mon dow   command" | crontab -
	crontab -l | { cat; echo "*/10 * * * * $application_dir/build-pxemenus  > $application_log/build-pxemenus.log"; } | crontab -
	crontab -l | { cat; echo "2-52/10 * * * * $application_dir/extract-isos  > $application_log/extract-isos.log"; } | crontab -
	crontab -l | { cat; echo "@weekly $application_dir/remove-older-iso-revisions  > $application_log/remove-older-isos.log"; } | crontab -
	crontab -l | { cat; echo "@weekly $application_dir/get-torrents  > $application_log/get-torrents.log"; } | crontab -
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
