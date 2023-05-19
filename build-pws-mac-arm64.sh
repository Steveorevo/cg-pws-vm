#!/bin/bash
#
# Virtuosoft build script for Code Garden PWS (Personal Web Server) Edition
# on macOS Apple Silicon M1 64-bit compatible systems.
#

# Check if Xcode is installed
if ! command -v xcode-select &> /dev/null; then
    echo "Xcode is not installed. Installing..."
    xcode-select --install
else
    echo "Xcode is already installed."
fi

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

# Check if ISO file already exists
ISO_URL="https://cdimage.debian.org/debian-cd/current/arm64/iso-cd/debian-11.7.0-arm64-netinst.iso"
ISO_FILENAME="debian-11.7.0-amd64-netinst.iso"
if [ ! -f "$ISO_FILENAME" ]; then
    echo "Downloading Debian ISO..."
    curl -o "$ISO_FILENAME" "$ISO_URL"
    echo "Download complete."
else
    echo "Debian ISO already downloaded."
fi

