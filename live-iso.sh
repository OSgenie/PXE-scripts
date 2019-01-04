#!/bin/bash
function live_casper ()
{
kernelpath=$bootfolder/casper

if [ -d $kernelpath ]; then
if [ -f $subfolder/casper/vmlinuz ]; then
	distro_kernel=vmlinuz
elif [ -f $subfolder/casper/vmlinuz.efi ]; then
	distro_kernel=vmlinuz.efi
else
	echo " not a live iso"
	break
fi

if [ -f $subfolder/casper/initrd.lz ]; then
	distro_ram_disk=initrd.lz
elif [ -f $subfolder/casper/initrd ]; then
	distro_ram_disk=initrd
else
	echo " not a live iso"
	break
fi

mkdir -p $tftp_folder/$kernelpath
cp -uv $subfolder/casper/$distro_kernel $tftp_folder/$kernelpath/
cp -uv $subfolder/casper/$distro_ram_disk $tftp_folder/$kernelpath/
cat >> $menupath << EOM
LABEL $revdate
MENU LABEL $revdate
    kernel $kernelpath/$distro_kernel
    append initrd=$kernelpath/$distro_ram_disk noprompt boot=casper url=$seed_path/$seed_file netboot=nfs nfsroot=$nfs_root_path/$distro/$revision ro toram -
EOM
else
	echo " not a live iso"
	break
fi
}

function live_casper_initrd_lz ()
{
kernelpath=$bootfolder/casper
if [ -f $subfolder/casper/vmlinuz ]; then
	mkdir -p $tftp_folder/$kernelpath
	cp -uv $subfolder/casper/vmlinuz $tftp_folder/$kernelpath/
	cp -uv $subfolder/casper/initrd.lz $tftp_folder/$kernelpath/
	cat >> $menupath << EOM
	LABEL $revdate
	MENU LABEL $revdate
	    kernel $kernelpath/vmlinuz
	    append initrd=$kernelpath/initrd.lz noprompt boot=casper url=$seed_path/$seed_file netboot=nfs nfsroot=$nfs_root_path/$distro/$revision ro toram -
EOM
elif [ -f $subfolder/casper/vmlinuz.efi ]; then
	mkdir -p $tftp_folder/$kernelpath
	cp -uv $subfolder/casper/vmlinuz.efi $tftp_folder/$kernelpath/
	cp -uv $subfolder/casper/initrd.lz $tftp_folder/$kernelpath/
	cat >> $menupath << EOM
	LABEL $revdate
	MENU LABEL $revdate
	    kernel $kernelpath/vmlinuz.efi
	    append initrd=$kernelpath/initrd.lz noprompt boot=casper url=$seed_path/$seed_file netboot=nfs nfsroot=$nfs_root_path/$distro/$revision ro toram -
EOM
else
	break
fi
}
