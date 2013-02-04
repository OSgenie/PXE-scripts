#!/bin/bash
folderpath=/var/nfs/transmission/complete

function create_array_of_valid_isos ()
{
array=$( ls $folderpath/ )
i=1
list=()
for option in $array; do
    iso_release='unknown'
    extension=${option##*.}
    name=$(basename $option .$extension)
    arr=$(echo $name | tr "-" "\n")
    for x in $arr; do
        if [[ $x = 'i386' || $x = 'x86' || $x = 'i686' || $x = '32bit' || $x = '32' ]]; then
            os_arch=i386
        elif [[ $x = 'amd64' || $x = 'x86_64' || $x = '64' || $x = '64bit' ]]; then
            os_arch=amd64
        fi
        if [ "${x:0:5}" == "$server_release" ]; then
            iso_release='match'
        fi
    done
    if [ $iso_release == 'match' ] && [ $server_arch == $os_arch ]; then        
            list=(${list[@]} $option)
    fi
done
}

function auto_generate_lists_of_valid_isos ()
{
supported_arches="amd64 i386"
supported_releases="12.04 12.10"
for server_release in $supported_releases; do
    for server_arch in $supported_arches; do
        updatelist=$server_release-$server_arch
        echo $updatelist
        create_array_of_valid_isos
        for (( i=0;i<${#list[@]};i++)); do
            echo ${list[$i]} | tee -a $folderpath/updatelists/$updatelist
        done
    done
done
}

function add_iso_to_list ()
{
available_lists=()
available_lists=(${available_lists[@]} $(ls $folderpath/updatelists/))
for (( i=0;i<${#available_lists[@]};i++)); do
    echo $i") "${available_lists[$i]}
done
echo ""
read -p "Enter the number for your choice: " choice
selected_list=${available_lists[$choice]}
}
    
function add_custom_isos_to_lists_of_valid_isos ()
{
all_isos=$( ls $folderpath/ )
for iso in $all_isos; do
    echo $iso
    iso_already_in_list=$(grep "$iso" $folderpath/updatelists/*)
    if [ "$iso_already_in_list" == "" ]; then
        echo "Which distrubution of Ubuntu is $iso based on?"
        add_iso_to_list
        echo $iso_name | tee -a $folderpath/updatelists/$selected_list
    fi
done
}

auto_generate_lists_of_valid_isos
add_custom_isos_to_lists_of_valid_isos