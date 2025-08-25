#!/usr/bin/env bash

SETTINGS_DIR="$HOME/.config/hypr/scripts/toggle"

if [ -f "$SETTINGS_DIR/use-waybar" ]; then
    ~/.config/waybar/launch.sh

elif [ -f "$SETTINGS_DIR/use-hyprbar" ]; then
    ~/.config/hypr/scripts/toggle/change-hyprbar.sh

elif [ -f "$SETTINGS_DIR/use-eww" ]; then
    ~/.config/eww/launch.sh

else
    echo "No bar selected, starting waybar by default"
    ~/.config/waybar/launch.sh
fi
