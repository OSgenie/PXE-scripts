#!/bin/bash
sudo install menu-update-all.sh /usr/local/bin/build-pxemenus
sudo install menu-distro-install.sh /usr/local/bin/menu-distro-install.sh
sudo install menu-distro-live.sh /usr/local/bin/menu-distro-live.sh
sudo install menu-distro-main.sh /usr/local/bin/menu-distro-main.sh
sudo install menu-distro-stock.sh /usr/local/bin/menu-distro-stock.sh
sudo install menu-main.sh /usr/local/bin/menu-main.sh
#menu-utilities.sh

echo "# m h  dom mon dow   command" | sudo crontab -
sudo crontab -l | { cat; echo "5-55/10 * * * * /usr/local/bin/build-pxemenus"; } | sudo crontab -

