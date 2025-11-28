#!/bin/bash

# Remove all default omarchy web apps

if ! command -v omarchy-webapp-remove &> /dev/null; then
    echo "Error: omarchy-webapp-remove not found. Is omarchy installed?"
    exit 1
fi

echo "Removing default omarchy web apps..."
omarchy-webapp-remove "Basecamp" "WhatsApp" "Google Photos" "Google Contacts" "Google Messages" "ChatGPT" "YouTube" "GitHub" "X" "Figma" "Discord" "HEY" "Zoom"

echo "Removal complete."