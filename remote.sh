#!/bin/bash

#
# Remote script to install and configure our Code Garden PWS (Personal Web Server) Edition
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
bash hst-install.sh --apache yes --phpfpm yes --multiphp yes --vsftpd yes --proftpd no --named no --mysql yes --postgresql yes --exim no --dovecot no --sieve no --clamav no --spamassassin no --iptables yes --fail2ban no --quota no --api yes --interactive no --with-debs no  --port '8083' --hostname 'cp.dev.cc' --email 'pws@dev.cc' --password 'personal-web-server' --lang 'en' --force

# Adjusting nginx.service file
echo "Adjusting nginx.service file."
line_to_add="ExecStartPre=/bin/sleep 3"
temp_file="/tmp/nginx.service.temp"
line_number=$(sudo awk '/\[Service\]/ { print NR+1; exit }' /lib/systemd/system/nginx.service)
cp /lib/systemd/system/nginx.service "$temp_file"
sed -i "${line_number}i\\${line_to_add}" "$temp_file"
cp "$temp_file" /lib/systemd/system/nginx.service
rm "$temp_file"

# Reboot the server
echo "Rebooting the server."
shutdown -r now


