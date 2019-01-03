#!/bin/bash
script_dir=/usr/local/bin/torrent.configs
distros_base=torrent.configs/*
download_folder=/var/nfs/transmission/torrents/

for distros in $distros_base; do
  for distro in $distros; do
    distros=$(basename $distros)
    distro=$(basename -s .config $distro)
    source $script_dir/$distros/$distro".config"
    source $script_dir/$distros/$distros".arches"
    for arch in $arches; do
      for flavor in $flavors; do
        source $script_dir/$distros/$distros".releases"
        for release in $releases; do
          for i in {10..0}; do
            source $script_dir/$distros/$distro".config"
            if [ -f $distro"-"$release"."$i"-"$flavor"-"$arch".iso.torrent.added" ] || [ -f  $distro"-"$release"-"$flavor"-"$arch".iso.torrent.added" ];then
              break
            fi
            cd $download_folder
            if [ $i == 0 ];then
              echo "checking "$release_server"/"$release_folder"/"$distro"-"$release"-"$flavor"-"$arch".iso.torrent"
              /usr/bin/wget --no-clobber -t 1 -T 3 $release_server"/"$release_folder"/"$distro"-"$release"-"$flavor"-"$arch".iso.torrent"
            else
              echo "checking "$release_server"/"$release_folder"/"$distro"-"$release"."$i"-"$flavor"-"$arch".iso.torrent"
              /usr/bin/wget --no-clobber -t 1 -T 3 $release_server"/"$release_folder"/"$distro"-"$release"."$i"-"$flavor"-"$arch".iso.torrent"
            fi
            if [ -f $distro"-"$release"."$i"-"$flavor"-"$arch".iso.torrent" ] || [ -f  $distro"-"$release"-"$flavor"-"$arch".iso.torrent" ];then
              break
            fi
          done
        done
      done
    done
  done
done
