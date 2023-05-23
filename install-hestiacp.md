## Install HestiaCP
Next, you will want to install the Hestia Control Panel project with the given options. Because the installation commands are lengthy, it's best to copy and paste them. However, QEMU's generic display window does not support Host-to-Guest clipboard integration; therefore we will want to login to the VM using an SSH/Terminal session:

* Start your OS' shell (i.e. Terminal.app in macOS) and enter the command:

```
ssh debian@localhost -p 8022
```

* Answer 'yes' if prompted to allow connection the first time.
* At the 'password:' prompt, type the password, 'personal-web-server' and press enter.

After login, we'll want remove apparmor and install (Hestia Control Panel)[https://hestiacp.com]. Copy and paste the following commands to the shell (followed by pressing enter):

```
sudo apt remove -y apparmor
cd /tmp
wget https://raw.githubusercontent.com/hestiacp/hestiacp/release/install/hst-install.sh
sudo bash hst-install.sh --apache yes --phpfpm yes --multiphp yes --vsftpd yes --proftpd no --named no --mysql yes --postgresql yes --exim no --dovecot no --sieve no --clamav no --spamassassin no --iptables yes --fail2ban no --quota no --api yes --interactive yes --with-debs no  --port '8083' --hostname 'cp.dev.cc' --email 'pws@dev.cc' --password 'personal-web-server' --lang 'en' 
```

* At the 'password:' prompt, type the password, 'personal-web-server' and press enter.
* When prompted to install HestiaCP Y/N, answer yes.

&nbsp;

-----

&nbsp;
Continue with **[Install HCPP](install-hcpp.md)**