#!/bin/bash

# Remote server details
remote_user="debian"
remote_host="local.dev.cc"
remote_password="personal-web-server"
remote_port="8022"

# Local script file to transfer
local_script_file="remote.sh"

# Remote script file destination
remote_script_file="/tmp/remote.sh"

# Warn user
clear
echo "!!! This script will take a LONG time to run. !!!"
echo "Please be patient and do not interrupt the process."
echo ""

# SSH connection and script transfer
sshpass -p "$remote_password" scp -o StrictHostKeyChecking=no -P "$remote_port" "$local_script_file" $remote_user@$remote_host:$remote_script_file

# SSH connection and script execution with sudo
sshpass -p "$remote_password" ssh -o StrictHostKeyChecking=no -p "$remote_port" $remote_user@$remote_host "echo '$remote_password' | sudo -S bash $remote_script_file"
echo "Finished modifications and HestiaCP installation"