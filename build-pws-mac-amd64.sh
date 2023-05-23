#!/bin/bash
#
# Virtuosoft build script for Code Garden PWS (Personal Web Server) Edition
# on macOS x86 64-bit compatible systems.
#

# Check if the CPU architecture indicates an Intel-based Mac
cpu_arch=$(sysctl -n machdep.cpu.brand_string)
if [[ $cpu_arch == *"Intel"* ]]; then
    echo "This is an Intel-based Mac."
else
    echo "This is not an Intel-based Mac."
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

# Check if ISO file already exists
ISO_URL="https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-11.7.0-amd64-netinst.iso"
ISO_FILENAME="debian-11.7.0-amd64-netinst.iso"
if [ ! -f "build/$ISO_FILENAME" ]; then
    echo "Downloading Debian ISO..."
    curl -L -o "build/$ISO_FILENAME" "$ISO_URL"
    echo "Download complete."
else
    echo "Debian ISO already downloaded."
fi

## Create the virtual disk images with max ability at 2TB
if [ ! -f "build/disk-amd64.img" ]; then
    qemu-img create -f qcow2 build/disk-amd64.img 2000G
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
cd build

sudo qemu-system-x86_64 \
    -accel hvf \
    -cpu Haswell-v1 \
    -smp 3 \
    -m 4G \
    -vga virtio \
    -display default,show-cursor=on \
    -device virtio-net-pci,netdev=net0 \
    -netdev user,id=net0,hostfwd=tcp::8022-:22,hostfwd=tcp::80-:80,hostfwd=tcp::443-:443,hostfwd=tcp::8083-:8083 \
    -cdrom debian-11.7.0-amd64-netinst.iso \
    -drive if=virtio,format=qcow2,file=disk-amd64.img
cd ..
