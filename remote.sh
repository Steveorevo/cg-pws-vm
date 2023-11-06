#!/bin/bash

#
# Remote script to install and configure our Devstia Preview virtual machine.
# This script is run on the remote server with sudo permissions from the /tmp directory; it
# is invoked by the install.sh script.
#

echo ""
echo "Starting automated HestiaCP installation"
echo "This will take a long while, please be patient..."
sleep 1

# Replace line in /etc/default/grub
echo "Updating GRUB timeout value to zero."
new_timeout_value="GRUB_TIMEOUT=0"
sed -i "s/GRUB_TIMEOUT=.*/$new_timeout_value/" /etc/default/grub
update-grub

# Remove apparmor
echo "Removing AppArmor."
apt remove -y apparmor

# Download HesitaCP Installer
echo "Downloading HestiaCP Installer."
cd /tmp
wget https://raw.githubusercontent.com/hestiacp/hestiacp/release/install/hst-install.sh

# Install HestiaCP
echo "Installing HestiaCP."
bash hst-install.sh --apache yes --phpfpm yes --multiphp yes --vsftpd yes --proftpd no --named no --mariadb yes --mysql8 no --postgresql yes --exim no --dovecot no --sieve no --clamav no --spamassassin no --iptables yes --fail2ban no --quota no --api yes --interactive no --with-debs no  --port '8083' --hostname 'local.dev.pw' --email 'devstia@dev.pw' --password 'preview' --lang 'en' --force

# Add ll globally
cat <<EOT >> /etc/bash.bashrc
alias ll='ls -alF'
EOT

# Reboot the server
echo "Rebooting the server."
shutdown -r now
