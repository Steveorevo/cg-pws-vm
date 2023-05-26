## Install HestiaCP
Next, you will want to install the Hestia Control Panel project with the given options. Because the installation commands are lengthy, it's best to copy and paste them. However, QEMU's generic display window does not support Host-to-Guest clipboard integration; therefore we will want to login to the VM using an SSH/Terminal session:

* Start your OS' shell (i.e. Terminal.app in macOS) and enter the command:

```
ssh debian@localhost -p 8022
```

* Answer 'yes' if prompted to allow connection the first time.
* At the 'password:' prompt, type the password, 'personal-web-server' and press enter.

After login, we'll need to modify the nginx.service file to help avoid an Nginx binding error as the network comes online. Edit the file with the following command:

```
sudo nano /lib/systemd/system/nginx.service
```

Add the following line in the [Service] section:

```
ExecStartPre=/bin/sleep 3
```

While we're at it, let's remove the 5 second delay in grub. Edit the following file with the command:

```
sudo nano /etc/default/grub
```

Check the valud for `GRUB_TIMEOUT` to zero; it should read:
```
GRUB_TIMEOUT=0
```

Then be sure to execute to have changes take effect:

```
sudo update-grub
```

Then install Virtio 9p file system support:

```
sudo apt install qemu-guest-agent spice-vdagent
```

Followed by editing the file to load support at boot:

```
sudo nano /etc/modules
```

Add the following lines to the end of the file and save it:
```
9pnet_virtio
9p
```

Next, we'll want remove apparmor  and install (Hestia Control Panel)[https://hestiacp.com]. Copy and paste the following commands to the shell (followed by pressing enter):

```
sudo apt remove -y apparmor
cd /tmp
wget https://raw.githubusercontent.com/hestiacp/hestiacp/release/install/hst-install.sh
sudo bash hst-install.sh --apache yes --phpfpm yes --multiphp yes --vsftpd yes --proftpd no --named no --mysql yes --postgresql yes --exim no --dovecot no --sieve no --clamav no --spamassassin no --iptables yes --fail2ban no --quota no --api yes --interactive yes --with-debs no  --port '8083' --hostname 'cp.dev.cc' --email 'pws@dev.cc' --password 'personal-web-server' --lang 'en' 
```

* At the 'password:' prompt, type the password, 'personal-web-server' and press enter.
* When prompted to install HestiaCP Y/N, answer yes.

Be patient, the HestiaCP project will take some time to complete installation. After installation completes, the system will reboot.

&nbsp;

-----

&nbsp;
Continue with **[Install HCPP](install-hcpp.md)**