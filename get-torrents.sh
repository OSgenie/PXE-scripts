#!/bin/bash
distro_dir=/usr/local/bin/torrent.configs
download_folder=/var/nfs/transmission/torrents/

for distros in $distro_dir/*; do
  for distro in $distros/*; do
    distros=$(basename $distros)
    distro=$(basename -s .config $distro)
    source $distro_dir/$distros/$distro".config"
    source $distro_dir"/."$distros"/arches"
    for arch in $arches; do
      for flavor in $flavors; do
        source $distro_dir"/."$distros"/releases"
        for release in $releases; do
          for i in {6..0}; do
            source $distro_dir/$distros/$distro".config"
            cd $download_folder
            if [ -f $distro"-"$release"."$i"-"$flavor"-"$arch".iso.torrent.added" ] || [ -f  $distro"-"$release"-"$flavor"-"$arch".iso.torrent.added" ];then
              break
            fi
            if [ $i == 0 ];then
              echo "checking "$release_server"/"$release_folder"/"$distro"-"$release"-"$flavor"-"$arch".iso.torrent"
              /usr/bin/wget -t 1 -T 2 $release_server"/"$release_folder"/"$distro"-"$release"-"$flavor"-"$arch".iso.torrent"
            else
              echo "checking "$release_server"/"$release_folder"/"$distro"-"$release"."$i"-"$flavor"-"$arch".iso.torrent"
              /usr/bin/wget -t 1 -T 2 $release_server"/"$release_folder"/"$distro"-"$release"."$i"-"$flavor"-"$arch".iso.torrent"
            fi
            if [ -f $distro"-"$release"."$i"-"$flavor"-"$arch".iso.torrent" ] || [ -f  $distro"-"$release"-"$flavor"-"$arch".iso.torrent" ];then
              break
            fi
          done
        done
      done
    done
  done
done  | tac
