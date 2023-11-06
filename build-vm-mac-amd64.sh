#!/bin/bash
#
# Virtuosoft build script for Devstia Preview (a localhost development server)
# on macOS x86 64-bit compatible systems.
#

# Check if the CPU architecture indicates an Intel-based Mac
cpu_arch=$(sysctl -n machdep.cpu.brand_string)
if [[ $cpu_arch == *"Intel"* ]]; then
    echo "This is an Intel-based Mac."
else
    echo "This script is only compatible with Intel-based Macs. Exiting..."
    exit 1
fi

# Check if Xcode is installed
if ! command -v xcode-select &> /dev/null; then
    echo "Xcode is not installed. Installing..."
    xcode-select --install
else
    echo "Xcode is already installed."
fi

# macOS goof; just need to invoke sudo once prior, yet NOT for brew install
sudo whoami

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "Homebrew is not installed. Installing..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Homebrew is already installed."
fi

# Check if sshpass is installed
if ! brew list --formula | grep -q '^sshpass$'; then
    echo "sshpass is not installed. Installing..."
    brew install --force hudochenkov/sshpass/sshpass
else
    echo "sshpass is already installed."
fi

# Check if QEMU is installed
if ! brew list --formula | grep -q '^qemu$'; then
    echo "QEMU is not installed. Installing..."
    brew install --force qemu
else
    echo "QEMU is already installed."
fi

# Check if build folder exists
if [ ! -d "build" ]; then
    echo "Creating the build folder..."
    mkdir "build"
    echo "Build folder created!"
else
    echo "Build folder already exists."
fi

## Copy EFI over to build folder
#if [ ! -f "build/efi_amd64.img" ]; then
#    cp /usr/local/share/qemu/edk2-x86_64-code.fd build/efi_amd64.img
#    cat /usr/local/share/qemu/edk2-i386-vars.fd /usr/local/share/qemu/edk2-x86_64-code.fd > build/efi_amd64_vars.img
#else
#    echo "BIOS file already extracted."
#fi

# Check if BIOS file already exists
if [ ! -f "build/bios.img" ]; then
    echo "Copying BIOS file..."
    cp /usr/local/share/qemu/bios.bin build/bios.img
else
    echo "BIOS file already copied."
fi

# Check if ISO file already exists
ISO_FILENAME="debian-12.0.0-amd64-netinst.iso"
ISO_URL="https://cdimage.debian.org/cdimage/archive/12.0.0/amd64/iso-cd/$ISO_FILENAME"
if [ ! -f "build/$ISO_FILENAME" ]; then
    echo "Downloading Debian ISO..."
    curl -L -o "build/$ISO_FILENAME" "$ISO_URL"
    echo "Download complete."
else
    echo "Debian ISO already downloaded."
fi

## Create the virtual disk images with the max abilitiy of 2TB
if [ ! -f "build/devstia-amd64.img" ]; then
    qemu-img create -f qcow2 build/devstia-amd64.img 2000G
    echo "Virtual disk image created!"
else
    echo "Virtual disk image already exists. May not be clean; exiting."
    # Display a message
    echo "Press any key to continue..."

    # Pause the script until a key is pressed
    read -n 1 -s -r
    exit 1
fi

# Run QEMU with the following options to start the debian installation process
echo "Booting Debian Linux installer..."
cd build || exit
qemu-system-x86_64 \
        -machine q35,vmport=off -accel hvf \
        -cpu qemu64-v1 \
        -vga virtio \
        -smp cpus=4,sockets=1,cores=4,threads=1 \
        -m 4G \
        -bios bios.img \
        -cdrom $ISO_FILENAME \
        -display default,show-cursor=on \
        -net nic -net user,hostfwd=tcp::8022-:22,hostfwd=tcp::80-:80,hostfwd=tcp::443-:443,hostfwd=tcp::8083-:8083 \
        -drive if=virtio,format=qcow2,file=devstia-amd64.img \
        -device virtio-balloon-pci
        # -device virtio-net-pci,netdev=net0 \
        # -netdev user,id=net0,hostfwd=tcp::8022-:22,hostfwd=tcp::80-:80,hostfwd=tcp::443-:443,hostfwd=tcp::8083-:8083 \
        # -drive if=pflash,format=raw,file=efi_amd64.img,readonly=on \
        # -drive if=pflash,format=raw,file=efi_amd64_vars.img,readonly=on \
cd ..
