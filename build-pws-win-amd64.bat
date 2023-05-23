@echo off
::
:: Virtuosoft build script for Code Garden PWS (Personal Web Server) Edition
:: on Windows x86 64-bit compatible systems.
::

:: Check if QEMU is installed
where qemu-system-x86_64 >nul 2>&1
if %errorlevel% neq 0 (
    echo QEMU is not installed. Downloading and installing...
    curl -o qemu-w64-setup-20230424.exe https://qemu.weilnetz.de/w64/2023/qemu-w64-setup-20230424.exe
    qemu-w64-setup-20230424.exe /S
    echo QEMU installation completed.
) else (
    echo QEMU is already installed.
)

:: Check if ISO file already exists
set ISO_URL=https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-11.7.0-amd64-netinst.iso
set ISO_FILENAME=debian-11.7.0-amd64-netinst.iso
if not exist "%ISO_FILENAME%" (
    echo Downloading Debian ISO...
    curl -L -o "%ISO_FILENAME%" "%ISO_URL%"
    echo Download complete.
) else (
    echo Debian ISO already downloaded.
)

@REM # Untar the BIOS file
@REM if [ ! -f "build/bios_amd.img" ]; then
@REM     echo "Extracting BIOS file..."
@REM     tar -xf ./boot/bios_amd.tar.xz -C ./build
@REM     echo "Extraction complete."
@REM else
@REM     echo "BIOS file already extracted."
@REM fi

@REM # sudo qemu-system-x86_64 \
@REM #     -smp 3 \
@REM #     -m 4G \
@REM #     -drive if=virtio,format=qcow2,file=disk-amd64.img \
@REM #     -device virtio-net-pci,netdev=net0 \
@REM #     -netdev user,id=net0,hostfwd=tcp::8022-:22,hostfwd=tcp::80-:80,hostfwd=tcp::443-:443,hostfwd=tcp::8083-:8083 \
@REM #     -cdrom debian-11.7.0-amd64-netinst.iso \
@REM #     -boot d \
@REM #     -cpu kvm64 \
@REM #     -vga virtio \
@REM #     -accel hvf