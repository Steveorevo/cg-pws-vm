# cg-pws-vm
Scripts to create platform and architecture specific virtual machines for Code Garden's Personal Web Server Edition.

> :warning: !!! Note: this repo is in progress; when completed, a release will appear in the release tab.

## Building
Building a specific virtual machine for a given host requires running under the host operating system for the given script.

#### 1) Start by cloning this repo [via git](https://git-scm.com) to a local folder, followed by changing directories to that folder:
```
git clone https://github.com/steveorevo/cg-pws-vm cg-pws-vm
cd cg-pws-vm
```

#### 2) Next, execute the given shell script on your operating system's CLI/terminal:

* macOS x64
```
source ./build-pws-mac-amd64.sh
```
* macOS M1
```
source ß./build-pws-mac-arm64.sh
```
* Windows x64
```
./build-pws-win-amd64.bat
```
* Linux x64
```
./build-pws-lnx-amd64.sh
```
* Linux aarch64
```
./build-pws-lnx-arm64.sh
```
