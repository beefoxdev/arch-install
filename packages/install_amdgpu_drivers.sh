#!/usr/bin/env bash
# Script to optionally install AMD GPU drivers and related packages on Arch Linux.
# It prompts the user for confirmation before proceeding.

set -euo pipefail

# Function to prompt the user
prompt_install() {
    echo "Do you want to install AMD GPU drivers and related packages? (y/N)"
    read -r answer
    case "$answer" in
        [Yy]* ) return 0;;
        * ) return 1;;
    esac
}

if prompt_install; then
    echo "Installing AMD GPU drivers..."
    yay -Syu --noconfirm --needed \
        mesa \
        xf86-video-amdgpu \
        vulkan-radeon \
        libva-mesa-driver \
        mesa-vdpau \
        xorg-xrandr \
        amdgpu_top
    echo "Installation complete."
else
    echo "Skipping AMD GPU driver installation."
fi
