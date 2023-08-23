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

# Install HestiaCP Pluginable project
cd /tmp
git clone --depth 1 --branch "v1.0.0-beta.26" https://github.com/virtuosoft-dev/hestiacp-pluginable.git 2>/dev/null
mv hestiacp-pluginable/hooks /etc/hestiacp
rm -rf hestiacp-pluginable-main
/etc/hestiacp/hooks/post_install.sh
service hestia restart

# Install HCPP NodeApp
cd /usr/local/hestia/plugins
git clone --depth 1 --branch "v1.0.0-beta.9" https://github.com/virtuosoft-dev/hcpp-nodeapp.git nodeapp 2>/dev/null
cd /usr/local/hestia/plugins/nodeapp
./install
touch "/usr/local/hestia/data/hcpp/installed/nodeapp"

# Install HCPP NodeRED
cd /usr/local/hestia/plugins
git clone --depth 1 --branch "v1.0.3" https://github.com/virtuosoft-dev/hcpp-nodered.git nodered 2>/dev/null
cd /usr/local/hestia/plugins/nodered
./install
touch "/usr/local/hestia/data/hcpp/installed/nodered"

# Install HCPP MailCatcher
cd /usr/local/hestia/plugins
git clone --depth 1 --branch "v1.0.0-beta.7" https://github.com/virtuosoft-dev/hcpp-mailcatcher.git mailcatcher 2>/dev/null
cd /usr/local/hestia/plugins/mailcatcher
./install
php -r 'require_once("/usr/local/hestia/web/pluginable.php");global $hcpp;$hcpp->do_action("hcpp_plugin_installed", "mailcatcher");'
touch "/usr/local/hestia/data/hcpp/installed/mailcatcher"

# Install HCPP CG-PWS
cd /usr/local/hestia/plugins
git clone --depth 1 --branch "v1.0.0-beta.21" https://github.com/virtuosoft-dev/hcpp-cg-pws.git cg-pws 2>/dev/null
cd /usr/local/hestia/plugins/cg-pws
./install
touch "/usr/local/hestia/data/hcpp/installed/cg-pws"

# Install HCPP VSCode
cd /usr/local/hestia/plugins
git clone --depth 1 --branch "v1.0.0-beta.8" https://github.com/virtuosoft-dev/hcpp-vscode.git vscode 2>/dev/null
cd /usr/local/hestia/plugins/vscode
./install
touch "/usr/local/hestia/data/hcpp/installed/vscode"

# Install HCPP NodeBB
cd /usr/local/hestia/plugins
git clone --depth 1 --branch "v1.0.0-beta.6" https://github.com/virtuosoft-dev/hcpp-nodebb.git nodebb 2>/dev/null
cd /usr/local/hestia/plugins/nodebb
./install
touch "/usr/local/hestia/data/hcpp/installed/nodebb"

# Install HCPP Ghost
cd /usr/local/hestia/plugins
git clone --depth 1 --branch "v1.0.0-beta.4" https://github.com/virtuosoft-dev/hcpp-ghost.git ghost 2>/dev/null
cd /usr/local/hestia/plugins/ghost
./install
touch "/usr/local/hestia/data/hcpp/installed/ghost"

# Install HCPP WebDAV
cd /usr/local/hestia/plugins
git clone --depth 1 --branch "v1.0.0-beta.3" https://github.com/virtuosoft-dev/hcpp-webdav.git webdav 2>/dev/null
cd /usr/local/hestia/plugins/webdav
./install
touch "/usr/local/hestia/data/hcpp/installed/webdav"

# Create our pws user and package
cd /usr/local/hestia/bin
cat <<EOT >> /tmp/pws.txt
PACKAGE='pws'
WEB_TEMPLATE='default'
BACKEND_TEMPLATE='default'
PROXY_TEMPLATE='default'
DNS_TEMPLATE='default'
WEB_DOMAINS='unlimited'
WEB_ALIASES='unlimited'
DNS_DOMAINS='unlimited'
DNS_RECORDS='unlimited'
MAIL_DOMAINS='unlimited'
MAIL_ACCOUNTS='unlimited'
RATE_LIMIT='200'
DATABASES='unlimited'
CRON_JOBS='unlimited'
DISK_QUOTA='unlimited'
BANDWIDTH='unlimited'
NS='ns1.dev.cc,ns2.dev.cc'
SHELL='bash'
BACKUPS='0'
EOT
./v-add-user-package /tmp/pws.txt pws
./v-add-user pws personal-web-server pws@dev.cc pws "Personal Web Server"
./v-update-user-package pws
chsh -s /bin/bash pws
./v-add-user-composer pws
./v-add-user-wp-cli pws

# White label the HestiaCP control panel interface
./v-priv-change-sys-config-value LOGIN_STYLE old
./v-change-sys-config-value APP_NAME "CodeGarden PWS"
./v-change-sys-config-value FROM_NAME "CodeGarden PWS"

# Add the virtio pws appFolder mount point
mkdir -p /media/appFolder
cat <<EOT >> /etc/fstab

# Personal Web Server appFolder
appFolder /media/appFolder 9p _netdev,trans=virtio,version=9p2000.L,msize=104857600 0 0

EOT

# Customize our SSH login message
cat <<EOT >> /etc/update-motd.d/00-header
#!/bin/bash
printf '%b\n' '\033[2J\033[:H'
clear
asciiart="\e[38;5;244m Welcome to                             \e[38;5;65m▄\e[38;5;65m▄\e[38;5;71m▄\e[38;5;71m▄\e[38;5;65m═
\e[38;5;244m                                \e[38;5;65m▄\e[38;5;71m▄\e[38;5;71m▌\e[38;5;65m▄\e[38;5;34m▓\e[38;5;34m█\e[38;5;34m█ █\e[38;5;34m█\e[38;5;34m▓\e[38;5;34m▓\e[38;5;65m╨
\e[38;5;244m                             \e[38;5;65m╓\e[38;5;34m█\e[38;5;34m█\e[38;5;34m▓\e[38;5;71m▀\e[38;5;34m█\e[38;5;34m█\e[38;5;34m██\e[38;5;34m▀\e[38;5;34m▓\e[38;5;28m█\e[38;5;28m█\e[38;5;28m█
\e[38;5;244m                          \e[38;5;65m╓\e[38;5;34m▓\e[38;5;71m▓\e[38;5;34m█\e[38;5;34m██\e[38;5;65m╥\e[38;5;65m▄\e[38;5;34m█\e[38;5;34m█\e[38;5;34m▓\e[38;5;65m▀▓\e[38;5;34m█\e[38;5;34m█\e[38;5;34m█
\e[38;5;244m                         \e[38;5;34m▓\e[38;5;34m█\e[38;5;34m▓\e[38;5;34m█\e[38;5;34m█\e[38;5;34m█\e[38;5;65m▓\e[38;5;34m█\e[38;5;28m█\e[38;5;34m▄\e[38;5;34m█▀\e[38;5;34m█\e[38;5;34m█\e[38;5;34m█\e[38;5;28m▀\e[38;5;65m▌
\e[38;5;244m                        \e[38;5;34m▓\e[38;5;65m▄\e[38;5;65m▄\e[38;5;34m█\e[38;5;34m█\e[38;5;28m█\e[38;5;65m▄█\e[38;5;71m▄\e[38;5;40m█\e[38;5;34m▌ \e[38;5;34m▓\e[38;5;34m█\e[38;5;34m█\e[38;5;65m▀\e[38;5;65m▓\e[38;5;65m▌
\e[38;5;244m                        \e[38;5;34m█\e[38;5;34m█\e[38;5;34m█\e[38;5;28m█\e[38;5;28m▀\e[38;5;28m█\e[38;5;65m▀\e[38;5;71m▄\e[38;5;40m█\e[38;5;34m█\e[38;5;34m▓\e[38;5;34m█\e[38;5;34m██\e[38;5;65m╣\e[38;5;34m█\e[38;5;34m█
\e[38;5;244m                        \e[38;5;34m█\e[38;5;34m█\e[38;5;34m█ \e[38;5;28m▓\e[38;5;65m▌\e[38;5;65m▐\e[38;5;40m█▄\e[38;5;65m▄██\e[38;5;34m█\e[38;5;65m╚\e[38;5;34m█\e[38;5;34m█\e[38;5;28m▌
\e[38;5;244m                        \e[38;5;65m└\e[38;5;34m█\e[38;5;65m▓\e[38;5;34m█\e[38;5;34m█ \e[38;5;34m█\e[38;5;71m╣█\e[38;5;34m█\e[38;5;34m█\e[38;5;65m▌\e[38;5;65m▄\e[38;5;34m█\e[38;5;34m█\e[38;5;28m█
\e[38;5;244m                          \e[38;5;65m╙\e[38;5;34m█\e[38;5;65m─\e[38;5;65m▐\e[38;5;65m╚\e[38;5;34m█\e[38;5;34m█\e[38;5;34m█\e[38;5;65m▀\e[38;5;34m█\e[38;5;34m█\e[38;5;34m█\e[38;5;65m▀
\e[38;5;244m                           \e[38;5;34m█  \e[38;5;34m▀\e[38;5;65m▀\e[38;5;65m╝\e[38;5;65m▀\e[38;5;65m▀▀\e[38;5;65m└
\e[38;5;244m                           \e[38;5;71m▀
\e[38;5;244m       ▄██▄          █        ▄██▄               █
\e[38;5;244m      █▀     ▄█▄   ▄██  ▄██▄ █▀ ▄▄▄  ▄██ █▄█▄  ▄██  ▄██▄ █▄█▄ 
\e[38;5;244m      █▄    █   █ █  █ █ ▄▀  █▄  ▄█ █  █ █▀   █  █ █ ▄▀  █▀ ▀█
\e[38;5;244m       ▀██▀  ▀█▀   ▀██  ▀██▀  ▀██▀   ▀██ █     ▀██  ▀██▀ █   █
\e[38;5;244m
\e[38;5;244m                    Personal Web Server Edition
\e[38;5;244m                        (c) Virtuosoft 2023
\e[38;5;244m "
echo -e "\$asciiart"
EOT
chmod +x /etc/update-motd.d/00-header
: > /etc/motd

# Resolve localhost to control panel URL and update certificate
./v-add-web-domain-alias admin local.dev.cc localhost no
rm -f /home/admin/web/local.dev.cc/public_html/index.html
cat <<EOT >> /home/admin/web/local.dev.cc/public_html/index.php
<?php
\$content = shell_exec('cat /usr/local/hestia/nginx/conf/nginx.conf');
\$port = "8083";
if (preg_match('/\blisten\s+(\d+)\s+ssl\b/', \$content, \$matches)) {
    \$port = \$matches[1];
}
\$alt = "";
if ( isset( \$_GET['alt'] ) ) {
   \$alt = '/?alt=' . \$_GET['alt'];
}
\$redirectURL = "https://local.dev.cc:" . \$port . \$alt;
header("Location: " . \$redirectURL);
exit;
EOT
./v-invoke-plugin cg_pws_regenerate_certificates
./v-invoke-plugin cg_pws_regenerate_ssh_keys

# Install Samba with PWS share
apt install -y samba
cp /etc/samba/smb.conf /etc/samba/smb.conf.bak
cat <<EOT >> /etc/samba/smb.conf
[global]
   workgroup = WORKGROUP
   log file = /var/log/samba/log.%m

   max log size = 1000
   logging = file
   panic action = /usr/share/samba/panic-action %d
   server role = standalone server
   obey pam restrictions = yes
   unix password sync = yes
   passwd program = /usr/bin/passwd %u
   passwd chat = *Enter\snew\s*\spassword:* %n\n *Retype\snew\s*\spassword:* %n\n *password\supdated\ssuccessfully* .
   pam password change = yes
   map to guest = bad user
   usershare allow guests = yes

#======================= Share Definitions =======================

[homes]
   comment = Home Directories
   browseable = no
   read only = no
   create mask = 0700
   directory mask = 0700
   valid users = %S

[printers]
   comment = All Printers
   browseable = no
   path = /var/spool/samba
   printable = yes
   guest ok = no
   read only = yes
   create mask = 0700

[print$]
   comment = Printer Drivers
   path = /var/lib/samba/printers
   browseable = yes
   read only = yes
   guest ok = no

[PWS]
   comment = PWS files
   read only = no
   path = /home/pws/web
   guest ok = no
   directory mask = 0755
   create mask = 0644
EOT
./v-add-firewall-rule ACCEPT 0.0.0.0\/0 445 TCP SMB

# Backup hcpp.log for review
cp /tmp/hcpp.log /home/debian/hcpp.log

# Shutdown the server
echo "Shutting down the server."
shutdown now
