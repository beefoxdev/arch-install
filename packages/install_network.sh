#!/bin/bash

set -euo pipefail

# Use one Wi-Fi stack: NetworkManager + wpa_supplicant. Leaving iwd enabled in
# parallel can race for nl80211 interfaces and cause intermittent Wi-Fi drops.
yay -S --noconfirm --needed wireguard-tools networkmanager networkmanager-openvpn wpa_supplicant

sudo systemctl disable --now systemd-networkd.service 2>/dev/null || true
sudo systemctl disable --now iwd.service 2>/dev/null || true
sudo systemctl enable --now wpa_supplicant.service
sudo systemctl enable --now NetworkManager.service

# Keep systemd-resolved as the DNS owner. Omarchy and Docker install resolved
# drop-ins, and NetworkManager integrates with resolved when it is available.
sudo systemctl enable --now systemd-resolved.service
sudo mkdir -p /etc/NetworkManager/conf.d
sudo tee /etc/NetworkManager/conf.d/10-dns-systemd-resolved.conf >/dev/null <<'EOF'
[main]
dns=systemd-resolved
rc-manager=symlink
EOF

if [ ! -L /etc/resolv.conf ] || [ "$(readlink /etc/resolv.conf)" != "/run/systemd/resolve/stub-resolv.conf" ]; then
    sudo rm -f /etc/resolv.conf
    sudo ln -s /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
fi

# Some laptop Wi-Fi chipsets, including Framework's MediaTek mt7925e, drop
# connections under aggressive runtime Wi-Fi power save. Keep it disabled.
sudo tee /etc/NetworkManager/conf.d/20-wifi-powersave-off.conf >/dev/null <<'EOF'
[connection]
wifi.powersave=2
EOF

if [ -f /etc/udev/rules.d/99-wifi-powersave.rules ]; then
    sudo rm -f /etc/udev/rules.d/99-wifi-powersave.rules
    sudo udevadm control --reload
fi

for iface in /sys/class/net/*/wireless; do
    iface="$(basename "$(dirname "$iface")")"
    sudo iw dev "$iface" set power_save off 2>/dev/null || true
done

sudo systemctl restart NetworkManager.service systemd-resolved.service

# Check if NetworkManager TUI is installed
DESKTOP_FILE="$HOME/.local/share/applications/NetworkManager.desktop"
if [ ! -f "$DESKTOP_FILE" ]; then
    echo "Installing NetworkManager TUI shortcut..."

    # Ensure directories exist
    ICON_DIR="$HOME/.local/share/applications/icons"
    mkdir -p "$ICON_DIR"

    # Download icon
    ICON_PATH="$ICON_DIR/NetworkManager.png"
    if curl -sL -o "$ICON_PATH" "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/pi-alert.png"; then
        echo "Icon downloaded successfully."
    else
        echo "Failed to download icon."
        exit 1
    fi

    # Create desktop file
    cat > "$DESKTOP_FILE" << EOF
[Desktop Entry]
Version=1.0
Name=NetworkManager
Comment=NetworkManager TUI
Exec=xdg-terminal-exec -e nmtui
Terminal=false
Type=Application
Icon=$ICON_PATH
StartupNotify=true
StartupWMClass=TUI.float
EOF

    chmod +x "$DESKTOP_FILE"
    echo "NetworkManager TUI shortcut created."
else
    echo "NetworkManager TUI shortcut already exists."
fi

# Confirm configuration
echo "Network configuration complete."
echo "systemd-networkd status: $(systemctl is-enabled systemd-networkd.service 2>/dev/null || echo 'disabled')"
echo "iwd status: $(systemctl is-enabled iwd.service 2>/dev/null || echo 'disabled')"
echo "wpa_supplicant status: $(systemctl is-enabled wpa_supplicant.service 2>/dev/null || echo 'disabled')"
echo "systemd-resolved status: $(systemctl is-enabled systemd-resolved.service 2>/dev/null || echo 'disabled')"
echo "NetworkManager status: $(systemctl is-enabled NetworkManager.service)"
echo "resolv.conf: $(ls -l /etc/resolv.conf | awk '{print $9, $10, $11}')"
