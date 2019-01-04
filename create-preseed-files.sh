#!/bin/bash
source pxe.config
http_preseed_root=/var/nfs/pxeboot/preseed
source preseed.configs/network.config
source preseed.configs/domain.config

## ADD LOGIC in generating preseeds as well as PXE menus
# for default preseed
# for server suite
source preseed.configs/server-default.config

cat > $http_preseed_root/uinstall << \
EOF
  d-i	debian-installer/locale	string en_US.UTF-8
  d-i	debian-installer/splash boolean false

  d-i	console-setup/ask_detect	boolean false
  d-i	console-setup/layoutcode	string us
  d-i	console-setup/variantcode	string

  d-i	netcfg/get_nameservers	string $dns_name_servers
  d-i	netcfg/get_ipaddress	string $ip_address
  d-i	netcfg/get_netmask	string $network_netmask
  d-i	netcfg/get_gateway	string $network_gateway
  d-i	netcfg/confirm_static	boolean false

  # This automatically creates a standard unencrypted partitioning scheme.
  d-i partman-auto/disk string /dev/sda
  d-i partman-auto/method string regular
  d-i partman-lvm/device_remove_lvm boolean true
  d-i partman-md/device_remove_md boolean true
  d-i partman-lvm/confirm boolean true
  d-i partman-lvm/confirm_nooverwrite boolean true
  d-i partman-auto/choose_recipe select unencrypted-install
  d-i partman-auto/expert_recipe string \\
          unencrypted-install :: \\
                  1024 1024 1024 ext4 \\
                          \\$primary{ } \\$bootable{ } \\
                          method{ format } format{ } \\
                          use_filesystem{ } filesystem{ ext4 } \\
                          mountpoint{ /boot } \\
                  . \\
                  150% 150% 150% linux-swap \\
                          \\$primary{ } \\
                          method{ swap } format{ } \\
                  . \\
                  17408 100000000000 -1 ext4 \\
                          \\$primary{ } \\
                          method{ format } format{ } \\
                          use_filesystem{ } filesystem{ ext4 } \\
                          mountpoint{ / } \\
                  .

  d-i partman-md/confirm boolean false
  d-i partman-partitioning/confirm_write_new_label boolean false
  d-i partman/choose_partition select finish
  d-i partman/confirm boolean false
  d-i partman/confirm_nooverwrite boolean false

  d-i clock-setup/utc boolean true
  d-i time/zone string US/Eastern
  d-i	clock-setup/ntp	boolean true
  d-i	clock-setup/ntp-server	string ntp.ubuntu.com

  d-i	base-installer/kernel/image	string linux-server

  d-i	passwd/root-login	boolean false
  d-i	passwd/make-user	boolean true
  d-i	passwd/user-fullname	string ubuntu
  d-i	passwd/username	string ubuntu
  d-i	passwd/user-password-crypted	password $6$.1eHH0iY$ArGzKX2YeQ3G6U.mlOO3A.NaL22Ewgz8Fi4qqz.Ns7EMKjEJRIW2Pm/TikDptZpuu7I92frytmk5YeL.9fRY4.
  d-i	passwd/user-uid	string
  d-i	user-setup/allow-password-weak	boolean false
  d-i	user-setup/encrypt-home	boolean false
  d-i	passwd/user-default-groups	string adm cdrom dialout lpadmin plugdev sambashare

  d-i	apt-setup/services-select	multiselect security
  d-i	apt-setup/security_host	string security.ubuntu.com
  d-i	apt-setup/security_path	string /ubuntu

  d-i mirror/http/mirror select CC.archive.ubuntu.com
  d-i mirror/http/proxy string http://$server_ip:3142/

  d-i debian-installer/allow_unauthenticated	string false
  d-i	pkgsel/upgrade	select safe-upgrade
  d-i	pkgsel/language-packs	multiselect
  d-i	pkgsel/update-policy	select none
  d-i	pkgsel/updatedb	boolean true

  d-i	grub-installer/skip	boolean false
  d-i	lilo-installer/skip	boolean false
  d-i	grub-installer/only_debian	boolean true
  d-i	grub-installer/with_other_os	boolean true

  d-i	finish-install/keep-consoles	boolean false
  d-i	finish-install/reboot_in_progress	note

  d-i	cdrom-detect/eject	boolean true
  d-i	debian-installer/exit/halt	boolean false
  d-i	debian-installer/exit/poweroff	boolean false

  d-i	pkgsel/include string byobu vim openssh-server git-core landscape-common
  byobu	byobu/launch-by-default boolean true
EOF
