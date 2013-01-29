#!/bin/bash
githome="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

$githome/menu-distro-install.sh
$githome/menu-distro-live.sh
$githome/menu-distro-main.sh
$githome/menu-main.sh
