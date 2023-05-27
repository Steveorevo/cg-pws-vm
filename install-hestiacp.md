## Install HestiaCP
Next, you will want to install the Hestia Control Panel project. At this point the QEMU virtual machine instance should still be running and at the login prompt; leave this running. In another terminal window, we will run the install.sh script; it will connect to the VM instance and execute the commands needed to configure our VM and install HestiaCP:

* Start your OS' shell (i.e. Terminal.app in macOS) and `cd` into this project's folder, then enter the command:

```
./install.sh
```
Please be patient while this process will take quite a bit of time to download, install, and configure HestiaCP.

After the script completes, the VM should automatically reboot. We will then need to install HCPP; follow the instructions in the next guide. 

&nbsp;

-----

&nbsp;
Continue with **[Install HCPP](install-hcpp.md)**
