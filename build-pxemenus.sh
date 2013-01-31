#!/usr/bin/env bash
scriptdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

$scriptdir/create-install-menus.sh
$scriptdir/create-live-menus.sh
$scriptdir/create-stock-menus.sh
#$scriptdir/create-utility-menu.sh
$scriptdir/create-submenus.sh
$scriptdir/create-main-menu.sh