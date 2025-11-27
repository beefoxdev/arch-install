#!/bin/bash

# Install mise if not present
if ! command -v mise &> /dev/null; then
    echo "Installing mise..."
    yay -S --noconfirm --needed mise
fi

# Install Python latest
echo "Installing Python latest..."
mise use --global python@latest

# Install uv package manager
echo "Installing uv..."
curl -fsSL https://astral.sh/uv/install.sh | sh

echo "Python installation complete."