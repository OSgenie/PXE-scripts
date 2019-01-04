PXE-scripts
===========

## Written to run on the OSgenie ISO-PXE server.
https://github.com/OSgenie/ISO-PXE-server

## A collection of scripts to make LiveCD iso images PXE bootable.
Process occurs in 3 parts.
    1. Kernel is extracted to TFTP share
    2. Non-Kernel files are extracted to NFS share
    3. PXE menu entry is created for the iso

## Installs as part of the ISO-PXE server build,
To install as a stand alone run:
sudo ./install.sh

## Includes the following files
### install-PXE-scripts-to-crontab.sh
Installs the scripts and schedules a cron job
### nfs-extract-iso.sh
Extracts all iso files to NFS
### generate-update-lists.sh
Run this script to identify the architecture and release that each iso is based on. (Linux Mint 14 64bit is based on Ubuntu 12.10 amd64)
### build-pxemenus.sh
To be run as a cron job to build PXE menus.
### The create scripts build the respective menus -
create-install-menus.sh

create-live-menus.sh

create-main-menu.sh

create-server-alternate-menus.sh

create-stock-menus.sh

create-submenus.sh

create-utility-menu.sh
###preseed
Folder for Preseed files
###remove-older-iso-revisions.sh
Script for cleaning out older isos to preserve disk space
