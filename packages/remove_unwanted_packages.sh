#!/bin/bash

# Remove unwanted packages: 1password, signal, spotify

echo "Removing 1password packages..."
yay -R --noconfirm 1password-beta 1password-cli

echo "Removing signal-desktop..."
yay -R --noconfirm signal-desktop

echo "Removing spotify..."
yay -R --noconfirm spotify

echo "Package removal complete."