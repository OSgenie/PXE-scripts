#!/bin/bash
folderpath=/var/nfs/transmission/complete

function check_for_sudo ()
{
if [ $UID != 0 ]; then
        echo "You need root privileges"
        exit 2
fi
}

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
supported_releases="12.04 12.10 14.04 14.10 15.04 15.10 16.04 16.10 17.04 17.10 18.04 18.10 19.04"
for server_release in $supported_releases; do
    for server_arch in $supported_arches; do
        updatelist=$server_release-$server_arch
        if [ ! -f $folderpath/updatelists/$updatelist ]; then
            echo $updatelist
            create_array_of_valid_isos
            for (( i=0;i<${#list[@]};i++)); do
                echo ${list[$i]} | tee -a $folderpath/updatelists/$updatelist
            done
        fi
    done
done
}

function add_iso_to_list ()
{
available_lists=()
available_lists=(${available_lists[@]} $(ls $folderpath/updatelists/))
for (( i=0;i<${#available_lists[@]};i++)); do
    echo $((i+1))") "${available_lists[$i]}
done
echo ""
read -p "Enter the number for your choice: " choice
if [ ! -z $choice ]; then
    selected_list=${available_lists[$((choice-1))]}
else
    echo "Valid choice not received"
    add_iso_to_list
fi
}
    
function add_custom_isos_to_lists_of_valid_isos ()
{
all_isos=$( ls $folderpath/ )
for iso in $all_isos; do
    if [ "${iso##*.}" == "iso" ]; then
        iso_already_in_list=$(grep "$iso" $folderpath/updatelists/*)
        if [ -z "$iso_already_in_list" ]; then
            clear
            echo "Which distrubution of Ubuntu is $iso based on?"
            add_iso_to_list
            echo $iso | tee -a $folderpath/updatelists/$selected_list
        fi
    fi
done
}

check_for_sudo
auto_generate_lists_of_valid_isos
add_custom_isos_to_lists_of_valid_isos
