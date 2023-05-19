#!/bin/bash
#
# Virtuosoft build script for Code Garden PWS (Personal Web Server) Edition
# on macOS Apple Silicon M1 64-bit compatible systems.
#

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "Homebrew is not installed. Installing..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Homebrew is already installed."
fi
