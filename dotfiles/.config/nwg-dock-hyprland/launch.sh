#!/usr/bin/env bash
#    ___           __
#   / _ \___  ____/ /__
#  / // / _ \/ __/  '_/
# /____/\___/\__/_/\_\
#


config="$HOME/.config/gtk-3.0/settings.ini"
if [ ! -f $HOME/.config/ml4w/settings/dock-disabled ]; then
    killall nwg-dock-hyprland
    sleep 0.5
    prefer_dark_theme="$(grep 'gtk-application-prefer-dark-theme' "$config" | sed 's/.*\s*=\s*//')"
    if [ $prefer_dark_theme == 0 ]; then
        style="style-light.css"
    else
        style="style-dark.css"
    fi
    nwg-dock-hyprland -i 14 -w 4 -mb 4 -ml 4 -mr 4 -x -s $style -c  "rofi -show drun"
else
    echo ":: Dock disabled"
fi