#!/bin/bash

if [[ -z "$1" ]]; then
  echo "Usage: install_dev-env <node|python>" >&2
  exit 1
fi

# Install mise if not present
if ! command -v mise &> /dev/null; then
    echo "Installing mise..."
    yay -S --noconfirm --needed mise
fi

case "$1" in
node)
  echo "Installing Node.js LTS..."
  mise use --global node@lts
  echo "Node.js installation complete."
  ;;
python)
  echo "Installing Python latest..."
  mise use --global python@latest
  echo "Installing uv..."
  curl -fsSL https://astral.sh/uv/install.sh | sh
  echo "Python installation complete."
  ;;
*)
  echo "Unsupported tool: $1" >&2
  exit 1
  ;;
esac