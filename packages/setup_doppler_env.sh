#!/bin/bash

# Setup Doppler environment variables in .bashrc

# Check if Doppler is installed
if ! command -v doppler &> /dev/null; then
    echo "Doppler CLI not found. Please install it first using install_doppler-cli-bin.sh"
    exit 1
fi

# Check if logged in to Doppler
if ! doppler auth status &>/dev/null; then
    echo "Not logged in to Doppler. Starting login process..."
    doppler login
    if ! doppler auth status &>/dev/null; then
        echo "Login failed. Exiting."
        exit 1
    fi
fi

echo "Fetching environment variables from Doppler omarchy project prd config..."

# Get secrets, filter out VPN_ prefixed
SECRETS=$(doppler secrets download --project omarchy --config prd --format env 2>/dev/null | grep -v '^VPN_')

if [ -z "$SECRETS" ]; then
    echo "No secrets found or failed to fetch."
    exit 1
fi

BASHRC="$HOME/.bashrc"

echo "Updating .bashrc with environment variables..."

# Process each secret
echo "$SECRETS" | while IFS='=' read -r key value; do
    if [ -n "$key" ]; then
        # Escape special characters in value for sed
        escaped_value=$(printf '%s\n' "$value" | sed 's/[[\.*^$()+?{|]/\\&/g')
        if grep -q "^export $key=" "$BASHRC"; then
            # Replace existing
            sed -i "s|^export $key=.*|export $key=\"$value\"|" "$BASHRC"
            echo "Updated $key"
        else
            # Add new
            echo "export $key=\"$value\"" >> "$BASHRC"
            echo "Added $key"
        fi
    fi
done

echo "Environment variables setup complete. Run 'source ~/.bashrc' to apply changes."