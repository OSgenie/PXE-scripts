#!/bin/bash
source pxe.config
http_preseed_root=/var/nfs/pxeboot/preseed
source preseed.configs/network.config
source preseed.configs/domain.config

## ADD LOGIC in generating preseeds as well as PXE menus
# for default preseed
# for server suite
# change   d-i	pkgsel/upgrade	select safe-upgrade

source preseed.configs/server-default.config

cat > $http_preseed_root/uinstall << \
EOF
  # Installer Settings
  d-i	debian-installer/locale	string en_US.UTF-8
  d-i	debian-installer/splash boolean false
  # Language Settings
  d-i	console-setup/ask_detect	boolean false
  d-i	console-setup/layoutcode	string us
  d-i	console-setup/variantcode	string
  # Network Settings
  d-i partman/early_command \
    string kill-all-dhcp; netcfg
  d-i netcfg/disable_autoconfig boolean true
  d-i netcfg/dhcp_failed note
  d-i netcfg/dhcp_options select Configure network manually
  d-i	netcfg/get_ipaddress	string $ip_address
  d-i	netcfg/get_netmask	string $network_netmask
  d-i	netcfg/get_gateway	string $network_gateway
  d-i	netcfg/get_nameservers	string $dns_name_servers
  d-i	netcfg/confirm_static	boolean true
  # Hostname
  d-i netcfg/hostname string $host_name
  d-i netcfg/get_domain string $local_domain
  # This automatically creates a standard unencrypted partitioning scheme with seperate /var.
  d-i partman-auto/disk string /dev/sda
  d-i partman-auto/method string lvm
  d-i partman-lvm/device_remove_lvm boolean true
  d-i partman-md/device_remove_md boolean true
  d-i partman-lvm/confirm boolean true
  d-i partman-auto/expert_recipe string \\
  var_scheme :: \\
  1 1 1 free \\
  	\$iflabel{ gpt } \\
  	\$reusemethod{ } \\
  	method{ biosgrub } \\
    . \\
  128 512 256 ext2 \\
  	\$defaultignore{ } \\
  	method{ format } \\
  	format{ } \\
  	use_filesystem{ } \\
  	filesystem{ ext2 } \\
  	mountpoint{ /boot } \\
    . \\
  2000 3500 10000 \$default_filesystem \\
  	\$lvmok{ } \\
  	method{ format } \\
  	format{ } \\
  	use_filesystem{ } \\
  	\$default_filesystem{ } \\
  	mountpoint{ / } \\
    . \\
  100% 512 200% linux-swap \\
  	\$lvmok{ } \\
  	\$reusemethod{ } \\
  	method{ swap } \\
  	format{ } \\
    . \\
  1000 1500 -1 \$default_filesystem \\
  	\$lvmok{ } \\
  	method{ format } \\
  	format{ } \\
  	use_filesystem{ } \\
  	\$default_filesystem{ } \\
  	mountpoint{ /var } \\
    .
  d-i partman/default_filesystem string ext4
  d-i partman-partitioning/confirm_write_new_label boolean true
  d-i partman/choose_partition select finish
  d-i partman/confirm boolean true
  d-i partman/confirm_nooverwrite boolean true
  # Time Settings
  d-i clock-setup/utc boolean true
  d-i time/zone string US/Eastern
  d-i	clock-setup/ntp	boolean true
  d-i	clock-setup/ntp-server	string ntp.ubuntu.com
  # Base install
  d-i	base-installer/kernel/image	string linux-server
  # User Account
  d-i	passwd/root-login	boolean false
  d-i	passwd/make-user	boolean true
  d-i	passwd/user-fullname	string ubuntu
  d-i	passwd/username	string ubuntu
  d-i	passwd/user-password-crypted	password \$6\$.1eHH0iY\$ArGzKX2YeQ3G6U.mlOO3A.NaL22Ewgz8Fi4qqz.Ns7EMKjEJRIW2Pm/TikDptZpuu7I92frytmk5YeL.9fRY4.
  d-i	passwd/user-uid	string
  d-i	user-setup/allow-password-weak	boolean false
  d-i	user-setup/encrypt-home	boolean false
  d-i	passwd/user-default-groups	string adm cdrom dialout lpadmin plugdev sambashare
  # Apt Configuration
  d-i	apt-setup/services-select	multiselect security
  d-i	apt-setup/security_host	string security.ubuntu.com
  d-i	apt-setup/security_path	string /ubuntu
  d-i mirror/http/mirror select CC.archive.ubuntu.com
  d-i mirror/http/proxy string http://$server_ip:3142/
  # Additional Packages
  d-i debian-installer/allow_unauthenticated	string false
  d-i	pkgsel/upgrade	select none
  d-i	pkgsel/language-packs	multiselect
  d-i	pkgsel/update-policy	select none
  d-i	pkgsel/updatedb	boolean true
  # Grub Configuration
  d-i	grub-installer/skip	boolean false
  d-i	lilo-installer/skip	boolean false
  d-i	grub-installer/only_debian	boolean true
  d-i	grub-installer/with_other_os	boolean true
  # Finish Options
  d-i	finish-install/keep-consoles	boolean false
  d-i	finish-install/reboot_in_progress	note
  d-i	cdrom-detect/eject	boolean true
  d-i	debian-installer/exit/halt	boolean false
  d-i	debian-installer/exit/poweroff	boolean false
  # Post System Installation Tasks
  d-i	pkgsel/include string byobu vim openssh-server git-core landscape-common
  byobu	byobu/launch-by-default boolean true
EOF
