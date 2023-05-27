#!/bin/bash

#
# Remote script to install and configure our HCPP (Hestia Control Panel Plugins).
# This script is run on the remote server with sudo permissions from the /tmp directory; it
# is invoked by the install-hcpp.sh script.
#

echo ""
echo "Starting automated HCPP installation"
echo "This will take a long while, please be patient..."
sleep 1

## TODO: install each component one-at-a-time...
##
# * [HestiaCP-NodeApp](https://github.com/Steveorevo/hestiacp-nodeapp/blob/main/README.md)
# * [HestiaCP-MailCatcher](https://github.com/Steveorevo/hestiacp-mailcatcher)
# * [HestiaCP-VSCode](https://github.com/Steveorevo/hestiacp-vscode)
# * [HestiaCP-NodeRED](https://github.com/Steveorevo/hestiacp-nodered)
# * [HestiaCP-NodeBB](https://github.com/Steveorevo/hestiacp-nodebb)
# * [HestiaCP-Ghost](https://github.com/Steveorevo/hestiacp-ghost)

# Shutdown the server
echo "Shutting down the server."
shutdown now


