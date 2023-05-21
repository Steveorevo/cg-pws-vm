#!/bin/bash
#
# EFI and BIOS files needed to boot Debian 11.7.0 on QEMU.
# We can obtain these from a Ubuntu/Debian instance of QEMU + EFI
# and copy them to our build environment. They are small and 
# we've already included them in the repo for convenience. Use
# this script on a Ubuntu/Debian instance of QEMU + EFI to 
# update/obtain the files if needed.
#
if [ ! -f "/bin/qemu-system-x86_64" ]; then
    sudo apt -y install qemu-system qemu-efi
fi

## Prepare BIOS
if [ ! -f "bios_amd.img" ]; then
    cp /usr/share/ovmf/OVMF.fd bios_amd.img
fi

## Prepare EFI
if [ ! -f "efi_arm.img" ]; then
    truncate -s 64m efi_arm.img
    dd if=/usr/share/qemu-efi-aarch64/QEMU_EFI.fd of=efi_arm.img conv=notrunc
fi

## Compress and cleanup files 
if [ ! -f "efi_arm.tar.xz" ]; then
    tar -cJf efi_arm.tar.xz efi_arm.img
    rm efi_arm.img
fi
if [ ! -f "bios_amd.tar.xz" ]; then
    tar -cJf bios_amd.tar.xz bios_amd.img
    rm bios_amd.img
fi
