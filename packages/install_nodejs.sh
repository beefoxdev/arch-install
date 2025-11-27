#!/bin/bash

# Install mise if not present
if ! command -v mise &> /dev/null; then
    echo "Installing mise..."
    yay -S --noconfirm --needed mise
fi

# Install Node.js LTS
echo "Installing Node.js LTS..."
mise use --global node@lts

echo "Node.js installation complete."