#!/bin/bash
#
# Virtuosoft build script for CodeGarden PWS (Personal Web Server) Edition
# on macOS Apple Silicon M1 64-bit compatible systems.
#

# Check if the CPU architecture indicates an ARM-based Mac
cpu_arch=$(sysctl -n machdep.cpu.brand_string)
if [[ $cpu_arch == *"ARM"* ]]; then
    echo "This is an ARM-based Mac."
else
    echo "This script is only compatible with ARM-based Macs. Exiting..."
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

# Untar the EFI file
if [ ! -f "build/efi_arm.img" ]; then
    echo "Extracting EFI file..."
    tar -xf ./boot/efi_arm.tar.xz -C ./build
    cp build/efi_arm.img build/efi_arm2.img
    echo "Extraction complete."
else
    echo "BIOS file already extracted."
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
if [ ! -f "build/pws-amd64.img" ]; then
    qemu-img create -f qcow2 build/pws-amd64.img 2000G
    echo "Virtual disk image created!"
else
    echo "Virtual disk image already exists. May not be clean; exiting."
    # Display a message
    echo "Press any key to continue..."

    # Pause the script until a key is pressed
    read -n 1 -s -r
    exit 1
fi


# qemu-system-x86_64 \
#         -vga virtio \
#         -device e1000,mac=0A:ED:23:58:71:EA,netdev=net0 \
#         -netdev user,id=net0,hostfwd=tcp::8022-:22,hostfwd=tcp::80-:80,hostfwd=tcp::443-:443,hostfwd=tcp::8083-:8083 \
#         -cpu Haswell \
#         -smp cpus=3,sockets=1,cores=3,threads=1 \
#         -machine q35,vmport=off \
#         -accel hvf \
#         -global PIIX4_PM.disable_s3=1 \
#         -global ICH9-LPC.disable_s3=1 \
#         -drive if=pflash,format=raw,unit=0,file=efi_amd64.img,readonly=on \
#         -drive if=pflash,unit=1,file=efi_amd64_vars.img \
#         -m 4096 \
#         -drive if=virtio,format=qcow2,file=pws-amd64.img \
#         -device virtio-blk-pci,drive=driveB07F6855-4243-40E7-A46C-F857444E0A53,bootindex=0 \
#         -drive if=none,media=disk,id=driveB07F6855-4243-40E7-A46C-F857444E0A53,file=/Users/sjcarnam/Library/Containers/com.utmapp.UTM/Data/Documents/pws-mac-amd64.utm/Data/B07F6855-4243-40E7-A46C-F857444E0A53.qcow2,discard=unmap,detect-zeroes=unmap \
#         -fsdev "local,id=virtfs0,path=/Users/sjcarnam/Library/Application Support/@virtuosoft/cg-pws-app,security_model=mapped-xattr" \
#         -device virtio-9p-pci,fsdev=virtfs0,mount_tag=appFolder \
#         -fsdev "local,id=virtfs1,path=/Users/sjcarnam/Sites,security_model=mapped-xattr" \
#         -device virtio-9p-pci,fsdev=virtfs1,mount_tag=webFolder \
#         -name pws-mac-amd64 \
#         -uuid 7C16DB0F-BAB5-456F-87F6-81CD52347B62 \
#         -rtc base=localtime \
#         -device virtio-rng-pci \
#         -device virtio-balloon-pci


# sudo qemu-system-x86_64 \
#     -accel hvf \
#     -cpu Haswell-v1 \
#     -smp 3 \
#     -m 4G \
#     -vga virtio \
#     -display default,show-cursor=on \
#     -device virtio-net-pci,netdev=net0 \
#     -netdev user,id=net0,hostfwd=tcp::8022-:22,hostfwd=tcp::80-:80,hostfwd=tcp::443-:443,hostfwd=tcp::8083-:8083 \
#     -cdrom debian-11.7.0-amd64-netinst.iso \
#     -drive if=virtio,format=qcow2,file=pws-amd64.img