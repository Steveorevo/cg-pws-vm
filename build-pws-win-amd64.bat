@echo off
::
:: Virtuosoft build script for CodeGarden PWS (Personal Web Server) Edition
:: on Windows x86 64-bit compatible systems.
::

:: Check if QEMU is installed
if not exist "C:\Program Files\qemu\qemu-system-x86_64.exe" (
    echo QEMU is not installed. Downloading and installing...
    curl -o qemu-w64-setup-20230424.exe https://qemu.weilnetz.de/w64/2023/qemu-w64-setup-20230822.exe
    qemu-w64-setup-20230424.exe /S
    del qemu-w64-setup-20230424.exe
    echo QEMU installation completed.
) else (
    echo QEMU is already installed.
)
set PATH=%PATH%;"C:\Program Files\qemu"

:: Check if build folder exists
if not exist build (
    echo Creating build folder...
    mkdir build
    echo Build folder created.
) else (
    echo Build folder already exists.
)

:: Check if BIOS file already exists
if not exist "build\bios.img" (
    echo Copying BIOS file...
    copy "C:\Program Files\qemu\share\bios.bin" "build\bios.img"
) else (
    echo BIOS file already copied.
)

:: Check if ISO file already exists
set ISO_FILENAME="debian-12.0.0-amd64-netinst.iso"
set ISO_URL="https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/%ISO_FILENAME%"
if not exist "build\%ISO_FILENAME%" (
    echo Downloading Debian ISO...
    curl -L -o "build\%ISO_FILENAME%" "%ISO_URL%"
    echo Download complete.
) else (
    echo Debian ISO already downloaded.
)

:: Create the virtual disk images with the max abilitiy of 2TB
if not exist "build\pws-amd64.img" (
    qemu-img create -f qcow2 build\pws-amd64.img 2000G
    echo Virtual disk image created!
) else (
    echo Virtual disk image already created.
    REM exit
)

:: Run QEMU with the following options to start the debian installation process
echo Booting Debian Linux installer...
cd /d build || exit /b
qemu-system-x86_64 ^
        -machine q35,vmport=off -accel whpx,kernel-irqchip=off ^
        -cpu qemu64-v1 ^
        -vga virtio ^
        -smp cpus=4,sockets=1,cores=4,threads=1 ^
        -m 4G ^
        -bios bios.img ^
        -cdrom %ISO_FILENAME% ^
        -net nic -net user,hostfwd=tcp::8022-:22,hostfwd=tcp::80-:80,hostfwd=tcp::443-:443,hostfwd=tcp::8023-:8023 ^
        -drive if=virtio,format=qcow2,file=pws-amd64.img ^
        -device virtio-balloon-pci
        REM -display default,show-cursor=on ^
        REM -machine q35 -accel tcg ^
        REM -machine q35,vmport=off -accel whpx,kernel-irqchip=off ^
        REM -vga std ^
        REM -nographic
        REM -drive if=pflash,format=raw,file=efi_amd64.img,readonly=on ^
        REM -drive if=pflash,format=raw,file=efi_amd64_vars.img,readonly=on ^
        REM -device virtio-net-pci,netdev=net0 ^
        REM -netdev user,id=net0,hostfwd=tcp::%sshPort%-:22,hostfwd=tcp::80-:80,hostfwd=tcp::443-:443,hostfwd=tcp::%cpPort%-%cpPort%%samba% ^
        REM -fsdev local,id=virtfs0,path="%appFolder%",security_model=mapped-xattr,fmode=0644,dmode=0755 ^
        REM -device virtio-9p-2000,fsdev=virtfs0,mount_tag=appFolder ^
        REM -nographic
        REM -display default,show-cursor=on
        REM Reference qemu-system-x86_64.exe -boot d -cdrom debian-12.0.0-amd64-netinst.iso -m 4G -hda pws-amd64.img -cpu qemu64-v1 -vga virtio -smp 4,sockets=1,cores=4,threads=1 -machine q35,vmport=off -accel whpx,kernel-irqchip=off
cd ..
