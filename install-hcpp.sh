#!/bin/bash

# Remote server details
remote_user="debian"
remote_host="local.dev.pw"
remote_password="personalweb"
remote_port="8022"

# Local script file to transfer
local_script_file="remote-hcpp.sh"

# Remote script file destination
remote_script_file="/tmp/remote-hcpp.sh"

# Warn user
clear
echo "!!! HCPP installation will take a LONG time to run. !!!"
echo "Please be patient and do not interrupt the process."
echo ""

# SSH connection and script transfer
sshpass -p "$remote_password" scp -o StrictHostKeyChecking=no -P "$remote_port" "$local_script_file" $remote_user@$remote_host:$remote_script_file

# SSH connection and script execution with sudo
sshpass -p "$remote_password" ssh -o StrictHostKeyChecking=no -p "$remote_port" $remote_user@$remote_host "echo '$remote_password' | sudo -S bash $remote_script_file"
echo "Finished installing HCPP components for Devstia Personal Web"
sleep 3
echo ""
echo "Now compressing resulting files for redistribution"
if [ -f "build/devstia-amd64.img" ]; then
    echo "Found devstia-amd64.img, compressing with BIOS"
    cd ./build
    qemu-img convert -O qcow2 -c devstia-amd64.img devstia-amd64-compressed.img
    rm devstia-amd64.img
    mv devstia-amd64-compressed.img devstia-amd64.img
    tar -cJf devstia-amd64.tar.xz devstia-amd64.img bios.img
fi
if [ -f "build/devstia-arm64.img" ]; then
    echo "Found devstia-arm64.img, compressing with EFI"
    cd ./build
    qemu-img convert -O qcow2 -c devstia-arm64.img devstia-arm64-compressed.img
    rm devstia-arm64.img
    mv devstia-arm64-compressed.img devstia-arm64.img
    tar -cJf devstia-arm64.tar.xz devstia-arm64.img efi_arm64.img efi_arm64_vars.img
fi
echo "Done! Finished compression, exiting"
