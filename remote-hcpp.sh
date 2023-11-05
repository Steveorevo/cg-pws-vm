#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

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
git clone --depth 1 --branch "v1.0.0-beta.40" https://github.com/virtuosoft-dev/hestiacp-pluginable.git 2>/dev/null
rm -rf /etc/hestiacp/hooks
mv hestiacp-pluginable/hooks /etc/hestiacp
rm -rf hestiacp-pluginable-main
/etc/hestiacp/hooks/post_install.sh
service hestia restart

# Install HCPP Devstia Preview
cd /usr/local/hestia/plugins
git clone --depth 1 --branch "v1.0.0-beta.38" https://github.com/virtuosoft-dev/hcpp-dev-pw.git cg-pws 2>/dev/null
cd /usr/local/hestia/plugins/dev-pw
./install
touch "/usr/local/hestia/data/hcpp/installed/dev-pw"

# Install HCPP NodeApp
cd /usr/local/hestia/plugins
git clone --depth 1 --branch "v1.0.0-beta.16" https://github.com/virtuosoft-dev/hcpp-nodeapp.git nodeapp 2>/dev/null
cd /usr/local/hestia/plugins/nodeapp
./install
touch "/usr/local/hestia/data/hcpp/installed/nodeapp"
export NVM_DIR=/opt/nvm && source /opt/nvm/nvm.sh

# Install HCPP NodeRED
cd /usr/local/hestia/plugins
git clone --depth 1 --branch "v1.0.9" https://github.com/virtuosoft-dev/hcpp-nodered.git nodered 2>/dev/null
cd /usr/local/hestia/plugins/nodered
./install
touch "/usr/local/hestia/data/hcpp/installed/nodered"

# Install HCPP MailCatcher
cd /usr/local/hestia/plugins
git clone --depth 1 --branch "v1.0.0-beta.9" https://github.com/virtuosoft-dev/hcpp-mailcatcher.git mailcatcher 2>/dev/null
cd /usr/local/hestia/plugins/mailcatcher
./install
php -r 'require_once("/usr/local/hestia/web/pluginable.php");global $hcpp;$hcpp->do_action("hcpp_plugin_installed", "mailcatcher");'
touch "/usr/local/hestia/data/hcpp/installed/mailcatcher"

# Install HCPP NodeBB
cd /usr/local/hestia/plugins
git clone --depth 1 --branch "v1.0.0-beta.13" https://github.com/virtuosoft-dev/hcpp-nodebb.git nodebb 2>/dev/null
cd /usr/local/hestia/plugins/nodebb
./install
touch "/usr/local/hestia/data/hcpp/installed/nodebb"

# Install HCPP Ghost
cd /usr/local/hestia/plugins
git clone --depth 1 --branch "v1.0.0-beta.9" https://github.com/virtuosoft-dev/hcpp-ghost.git ghost 2>/dev/null
cd /usr/local/hestia/plugins/ghost
./install
touch "/usr/local/hestia/data/hcpp/installed/ghost"

# Install HCPP VitePress
cd /usr/local/hestia/plugins
git clone --depth 1 --branch "v1.0.0-beta.4" https://github.com/virtuosoft-dev/hcpp-vitepress.git vitepress 2>/dev/null
cd /usr/local/hestia/plugins/vitepress
./install
touch "/usr/local/hestia/data/hcpp/installed/vitepress"

# Install HCPP WebDAV
cd /usr/local/hestia/plugins
git clone --depth 1 --branch "v1.0.0-beta.5" https://github.com/virtuosoft-dev/hcpp-webdav.git webdav 2>/dev/null
cd /usr/local/hestia/plugins/webdav
./install
touch "/usr/local/hestia/data/hcpp/installed/webdav"

# Install HCPP Quickstart
cd /usr/local/hestia/plugins
git clone --depth 1 --branch "v1.0.0-beta.6" https://github.com/virtuosoft-dev/hcpp-quickstart.git quickstart 2>/dev/null
cd /usr/local/hestia/plugins/quickstart
./install
touch "/usr/local/hestia/data/hcpp/installed/quickstart"

# Install HCPP VSCode
cd /usr/local/hestia/plugins
git clone --depth 1 --branch "v1.0.0-beta.12" https://github.com/virtuosoft-dev/hcpp-vscode.git vscode 2>/dev/null
cd /usr/local/hestia/plugins/vscode
./install
touch "/usr/local/hestia/data/hcpp/installed/vscode"

# Install HCPP WP Global, then DISABLE it
cd /usr/local/hestia/plugins
git clone --depth 1 --branch "v1.0.0-beta.4" https://github.com/virtuosoft-dev/hcpp-wp-global.git wp-global 2>/dev/null
cd /usr/local/hestia/plugins/wp-global
./install
touch "/usr/local/hestia/data/hcpp/installed/wp-global"
mv /usr/local/hestia/plugins/wp-global /usr/local/hestia/plugins/wp-global.disabled

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
BACKUPS='365'
EOT
./v-add-user-package /tmp/pws.txt pws
./v-add-user devstia preview devstia@dev.pw devstia Devstia Preview
./v-update-user-package devstia
chsh -s /bin/bash devstia
./v-add-user-composer devstia
./v-add-user-wp-cli devstia
./v-change-sys-config-value POLICY_USER_EDIT_WEB_TEMPLATES yes
./v-change-sys-config-value POLICY_SYSTEM_HIDE_ADMIN yes
./v-change-user-role devstia admin

# Add ll, wp aliases for devstia
echo "alias wp=/home/devstia/.wp-cli/wp" >> /home/devstia/.bash_aliases
echo "alias ll='ls -alF'" >> /home/devstia/.bash_aliases

# White label the HestiaCP control panel interface
./v-priv-change-sys-config-value LOGIN_STYLE old
./v-change-sys-config-value APP_NAME "Devstia Preview"
./v-change-sys-config-value FROM_NAME "Devstia Preview"

# Install design-time plugins in /home/pws/tmp/wp-global
mkdir -p /home/pws/tmp/wp-global
git clone https://github.com/virtuosoft-dev/wp-login-bypass.git /home/pws/tmp/wp-global/wp-login-bypass
git clone https://github.com/norcross/airplane-mode.git /home/pws/tmp/wp-global/airplane-mode.disabled
git clone https://github.com/ServerPress/admin-color-bar.git /home/pws/tmp/wp-global/admin-color-bar
chown -R pws:pws /home/pws/tmp/wp-global

# Customize our SSH login message
cat <<EOT >> /etc/update-motd.d/00-header
#!/bin/bash
printf '%b\n' '\033[2J\033[:H'
clear
asciiart="\e[38;5;244m 
\e[38;5;244m                     \e[38;5;60m▒\e[38;5;130m▓\e[38;5;166m▄\e[38;5;167m▄
\e[38;5;244m   Welcome to        \e[38;5;67m▐\e[38;5;32m▒\e[38;5;94m▒\e[38;5;208m▒\e[38;5;208m▒\e[38;5;208m▌
\e[38;5;244m                     \e[38;5;66m▐\e[38;5;26m▒\e[38;5;32m▒\e[38;5;172m▒\e[38;5;214m▒\e[38;5;214m▒\e[38;5;214m▒
\e[38;5;244m   Devstia Preview   \e[38;5;60m▐\e[38;5;25m▓\e[38;5;25m▒\e[38;5;239m▒\e[38;5;214m▒\e[38;5;214m▒▒
\e[38;5;244m                     \e[38;5;60m▐\e[38;5;25m▓\e[38;5;25m▓\e[38;5;24m▓\e[38;5;202m▒\e[38;5;202m▒▒
\e[38;5;244m                     \e[38;5;60m▐\e[38;5;24m▓\e[38;5;24m▓\e[38;5;17m▓\e[38;5;202m▒\e[38;5;202m▒▒
\e[38;5;244m                     \e[38;5;60m▐\e[38;5;24m▓\e[38;5;24m▓\e[38;5;53m▓\e[38;5;196m▒\e[38;5;196m▒\e[38;5;160m▌
\e[38;5;244m             \e[38;5;68m▄\e[38;5;32m▒\e[38;5;33m▒\e[38;5;26m▒\e[38;5;25m▓\e[38;5;25m▓\e[38;5;25m▓\e[38;5;24m▓\e[38;5;24m▓\e[38;5;24m▓\e[38;5;24m▓\e[38;5;89m▓\e[38;5;160m▓\e[38;5;160m▓
\e[38;5;244m          \e[38;5;67m▒\e[38;5;68m░\e[38;5;32m░\e[38;5;26m▒\e[38;5;25m▓\e[38;5;25m▓\e[38;5;25m▓\e[38;5;24m▀\e[38;5;60m▀  \e[38;5;25m▓\e[38;5;25m▓\e[38;5;24m▓\e[38;5;124m▓\e[38;5;160m▓\e[38;5;160m▓
\e[38;5;244m        \e[38;5;67m░\e[38;5;67m░\e[38;5;67m░\e[38;5;31m▒\e[38;5;25m▓\e[38;5;25m▓▓▓     ▓\e[38;5;25m▓\e[38;5;24m▓\e[38;5;124m▓\e[38;5;124m▓\e[38;5;124m▌
\e[38;5;244m       \e[38;5;67m░\e[38;5;67m░\e[38;5;67m░\e[38;5;31m█\e[38;5;25m▓\e[38;5;25m▓▓\e[38;5;25m▓     \e[38;5;60m▐\e[38;5;25m▓\e[38;5;25m▓\e[38;5;236m▓\e[38;5;124m▓\e[38;5;124m▓
\e[38;5;244m      \e[38;5;32m▒\e[38;5;68m░░\e[38;5;32m░\e[38;5;32m▒\e[38;5;32m▒▒▒      \e[38;5;25m▓\e[38;5;25m▓\e[38;5;25m▓\e[38;5;1m▓\e[38;5;124m▓\e[38;5;124m▓
\e[38;5;244m      \e[38;5;32m▒\e[38;5;32m▒▒\e[38;5;33m▒\e[38;5;33m▒▒▒\e[38;5;32m▌      \e[38;5;25m▓\e[38;5;25m▓\e[38;5;24m▓\e[38;5;88m▓\e[38;5;88m▓\e[38;5;88m▓
\e[38;5;244m     \e[38;5;67m▐\e[38;5;33m▒\e[38;5;33m▒▒\e[38;5;33m▒\e[38;5;32m▒\e[38;5;32m▒\e[38;5;32m▒      \e[38;5;25m▓\e[38;5;25m▓\e[38;5;24m▓\e[38;5;53m▓\e[38;5;88m▓\e[38;5;88m▓\e[38;5;88m▌
\e[38;5;244m      \e[38;5;26m▒\e[38;5;26m▒▒\e[38;5;32m░\e[38;5;68m░\e[38;5;67m░\e[38;5;67m░\e[38;5;67m░    \e[38;5;32m▐\e[38;5;24m▓\e[38;5;24m▓\e[38;5;24m▓\e[38;5;53m▓\e[38;5;124m▓\e[38;5;124m▓\e[38;5;124m▌   \e[38;5;244m \xc2\xa92023 Virtuosoft
\e[38;5;244m      \e[38;5;60m▀\e[38;5;25m▓\e[38;5;25m▓\e[38;5;25m▓\e[38;5;67m░\e[38;5;67m░\e[38;5;31m█\e[38;5;67m░░ \e[38;5;67m▄\e[38;5;25m▓\e[38;5;60m▀ \e[38;5;24m▓\e[38;5;24m▓\e[38;5;25m▓\e[38;5;53m▓\e[38;5;124m▓\e[38;5;124m▓
\e[38;5;244m        \e[38;5;60m▀\e[38;5;24m▓\e[38;5;24m▓\e[38;5;24m▓\e[38;5;25m▓\e[38;5;25m▓\e[38;5;25m▓\e[38;5;60m▀     \e[38;5;60m▀\e[38;5;25m▓\e[38;5;25m▒▒\e[38;5;238m▒\e[38;5;89m▓\e[38;5;95m▄\e[38;5;95m▄
\e[38;5;244m "
echo -e "\$asciiart"
EOT
chmod +x /etc/update-motd.d/00-header
: > /etc/motd

# Add localhost alias to admin's local.dev.cc domain
./v-add-web-domain-alias admin local.dev.cc localhost no
./v-invoke-plugin dev_pw_regenerate_certificates
./v-invoke-plugin dev_pw_regenerate_ssh_keys

# Disable automatic updates for now
./v-delete-cron-hestia-autoupdate
./v-restart-cron

# Install Samba with Devstia share
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
   comment = Devstia files
   read only = no
   path = /home/devstia/web
   guest ok = no
   directory mask = 0755
   create mask = 0644
EOT
./v-add-firewall-rule ACCEPT 0.0.0.0\/0 445 TCP SMB
./v-add-sys-pma-sso

# Set the default passwords for Samba, HestiaCP, etc.
/usr/local/hestia/plugins/dev-pw/update-password.sh "preview"

# Update nginx.conf to support 250gb downloads
sed -i "s/client_max_body_size\s\+1024m;/client_max_body_size            250000m;/" /etc/nginx/nginx.conf
sed -i '/# Proxy settings/a \        proxy_max_temp_file_size        0;' /etc/nginx/nginx.conf

# Backup hcpp.log for review
cp /tmp/hcpp.log /home/debian/hcpp.log

# Cleanup
apt-get autoremove -y

# Shutdown the server
echo "Shutting down the server."
shutdown now
