## Install HCPP
After installing HestiaCP the system will reboot. You will need to login again to continue installing HestiaCP-Pluginable (HCPP) and the additional extensions that make up Code Garden PWS (Personal Web Server) edition. Use the following directions:

* Login via your OS' shell again (i.e. from Terminal.app in macOS) and enter the command:

```
ssh debian@localhost -p 8022
```

* At the 'password:' prompt, type the password, 'personal-web-server' and press enter.

Next, execute the following to install HestiaCP_Pluginable's install instructions:

* Switch to root user::

```
sudo -s
```

* At the 'password:' prompt, type the password, 'personal-web-server' and press enter.
* Download and move the files into place:

```
cd /tmp
wget https://github.com/Steveorevo/hestiacp-pluginable/archive/refs/heads/main.zip
unzip main.zip
mv hestiacp-pluginable-main/hooks /etc/hestiacp
rm -rf hestiacp-pluginable-main
rm main.zip
```

* Run the post_install.sh script and restart Hestia:
```
/etc/hestiacp/hooks/post_install.sh
service hestia restart
```

### Install HCPP Based Projects
Now we can install HCPP plugins that furnish us with Code Garden's (Core Open Developer Elements) support for NodeJS, Open VSCode Server, line-by-line debugging in both PHP and NodeJS, Node-RED, psuedo mail server and with client side preview, etc. 

Note: It's important to install these one-by-one and in the order listed to avoid any depedency conflicts and to ensure a stable installation. Further, be sure to verify their installation using HestiaCP's control panel itself.

Visit each of these repos and follow the **Installation** section for each:

* [HestiaCP-NodeApp](https://github.com/Steveorevo/hestiacp-nodeapp/blob/main/README.md#installation)
* [HestiaCP-MailCatcher](https://github.com/Steveorevo/hestiacp-mailcatcher#installation)
* [HestiaCP-VSCode](https://github.com/Steveorevo/hestiacp-vscode#installation)
* [HestiaCP-NodeRED](https://github.com/Steveorevo/hestiacp-nodered#installation)
* [HestiaCP-NodeBB](https://github.com/Steveorevo/hestiacp-nodebb#installation)
* [HestiaCP-Ghost](https://github.com/Steveorevo/hestiacp-ghost#installation)

After installing all the aforementioned HCPP plugins; you can shutdown the VM:

```
sudo shutdown now
```

Compress the resulting disk-amd64.img (or disk-arm64.img for ARM processors) using the following command; be sure to usr or replace amd64 or arm64 respectively:

```
tar -cJf disk-amd64.tar.xz disk-amd64.img
```

&nbsp;

-----
&nbsp;

Return to the **[README.md](README.md)** for additional instructions and up-to-date information.
