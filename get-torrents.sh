#!/bin/bash
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
distros=torrent.configs/*
download_folder=/var/nfs/transmission/torrents/

for distro in $distros; do
  distro=$(basename -s .config $distro)
  source torrent.configs/$distro".config"
  for arch in $arches; do
    for flavor in $flavors; do
      for release in $releases; do
        source $script_dir/$distro".config"
        for i in {10..0}; do
          cd $download_folder
          if [ $i == 0 ];then
            echo "checking "$release_server"/"$release_folder"/"$distro"-"$release"-"$flavor"-"$arch".iso.torrent"
            /usr/bin/wget --no-clobber -t 1 $release_server"/"$release_folder"/"$distro"-"$release"-"$flavor"-"$arch".iso.torrent"
          else
            echo "checking "$release_server"/"$release_folder"/"$distro"-"$release"."$i"-"$flavor"-"$arch".iso.torrent"
            /usr/bin/wget --no-clobber -t 1 $release_server"/"$release_folder"/"$distro"-"$release"."$i"-"$flavor"-"$arch".iso.torrent"
          fi
          if [ -f $distro"-"$release"."$i"-"$flavor"-"$arch".iso.torrent" ] || [ -f  $distro"-"$release"-"$flavor"-"$arch".iso.torrent" ] \
          || [ -f $distro"-"$release"."$i"-"$flavor"-"$arch".iso.torrent.added" ] || [ -f  $distro"-"$release"-"$flavor"-"$arch".iso.torrent.added" ];then
            break
          fi
        done
      done
    done
  done
done
