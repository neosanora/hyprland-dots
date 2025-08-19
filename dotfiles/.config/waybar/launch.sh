#!/usr/bin/env bash

#!/bin/bash
#                    __
#  _    _____ ___ __/ /  ___ _____
# | |/|/ / _ `/ // / _ \/ _ `/ __/
# |__,__/\_,_/\_, /_.__/\_,_/_/
#            /___/
#

# -----------------------------------------------------
# Prevent duplicate launches: only the first parallel
# invocation proceeds; all others exit immediately.
# -----------------------------------------------------

exec 200>/tmp/waybar-launch.lock
flock -n 200 || exit 0

# -----------------------------------------------------
# Quit all running waybar instances
# -----------------------------------------------------

killall waybar || true
pkill waybar || true
sleep 0.5

# -----------------------------------------------------
# Get current theme information from ~/.config/ml4w/settings/waybar-theme.sh
# -----------------------------------------------------

if [ -f ~/.config/ml4w/settings/waybar-theme.sh ]; then
    themestyle=$(cat ~/.config/ml4w/settings/waybar-theme.sh)
else
    touch ~/.config/ml4w/settings/waybar-theme.sh
    echo "$default_theme" >~/.config/ml4w/settings/waybar-theme.sh
    themestyle=$default_theme
fi

IFS=';' read -ra arrThemes <<<"$themestyle"
echo ":: Theme: ${arrThemes[0]}"

if [ ! -f ~/.config/waybar/themes${arrThemes[1]}/style.css ]; then
    themestyle=$default_theme
fi

# -----------------------------------------------------
# Loading the configuration
# -----------------------------------------------------

CONFIG="$HOME/.config/waybar/neobar/configs/config"
STYLE="$HOME/.config/waybar/neobar/styling/style.css"

if pgrep -x "waybar" > /dev/null; then
    killall waybar
else
    waybar -c "$CONFIG" -s "$STYLE" > /dev/null 2>&1 &
fi
