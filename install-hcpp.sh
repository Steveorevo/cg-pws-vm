#!/bin/bash

# Remote server details
remote_user="debian"
remote_host="local.dev.cc"
remote_password="preview"
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
echo "Finished installing HCPP components for CodeGarden PWS Edition"
sleep 3
echo ""
echo "Now compressing resulting files for redistribution"
if [ -f "build/pws-amd64.img" ]; then
    echo "Found pws-amd64.img, compressing with BIOS"
    cd ./build
    tar -cJf pws-amd64.tar.xz pws-amd64.img bios.img
    # tar -cJf pws-amd64.tar.xz pws-amd64.img efi_amd64.img efi_amd64_vars.img
fi
if [ -f "build/pws-arm64.img" ]; then
    echo "Found pws-arm64.img, compressing with BIOS"
    cd ./build
    tar -cJf pws-arm64.tar.xz pws-arm64.img bios.img
    # tar -cJf pws-arm64.tar.xz pws-arm64.img efi_arm64.img efi_arm64_vars.img
fi
echo "Done! Finished compression, exiting"
