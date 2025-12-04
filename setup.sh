#!/bin/bash

for script in packages/*.sh; do
    echo "Running $script"
    bash "$script"
done

bash ./install-hyprland-overrides.sh
bash ./install-dotfiles.sh
