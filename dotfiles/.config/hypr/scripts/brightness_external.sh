#!/usr/bin/env bash

arg=$1
state_file="$HOME/.config/hypr/scripts/assets/ext_monitor.txt"

set_brightness() {
    brightness=$1
    if grep -q 'brightness = ' "$state_file"; then
        sed -i "s/brightness = [0-9-]*/brightness = $brightness/" "$state_file"
    else
        echo "brightness = $brightness" > "$state_file"
    fi
}

set_script_state() {
    isRunning=$1
    if grep -q 'script_state = ' "$state_file"; then
        sed -i "s/script_state = [0-1]*/script_state = $isRunning/" "$state_file"
    else
        echo "script_state = $isRunning" >> "$state_file"
    fi
}

perform_brightness_action() {
    set_script_state 1
    ddcutil setvcp 10 "$1"
    set_brightness "$1"
    set_script_state 0
}

# Init state file
if [ -f "$state_file" ]; then
    brightness=$(grep -oP 'brightness =\s+\K\d+' "$state_file" || echo 60)
    isRunning=$(grep -oP 'script_state =\s+\K\d+' "$state_file" || echo 0)
else
    brightness=60
    isRunning=0
    set_brightness $brightness
    set_script_state $isRunning
fi

# Remove comma if any
brightness=$(echo "$brightness" | tr -d ',')

# Argument check
if [[ $arg =~ ^[+-]?[0-9]+$ ]]; then
    if [[ $arg -gt 0 ]]; then
        new_brightness=$((brightness + $arg))
    else
        new_brightness=$((brightness + $arg))
    fi

    # Clamp range 0–100
    (( new_brightness < 0 )) && new_brightness=0
    (( new_brightness > 100 )) && new_brightness=100

    # Notifications
    if [ "$new_brightness" -eq 100 ]; then
        dunstify -h string:x-dunst-stack-tag:brightness_ext "Full Brightness" --icon="$HOME/.config/hypr/scripts/assets/brightness.svg"
    elif [ "$new_brightness" -eq 0 ]; then
        dunstify -h string:x-dunst-stack-tag:brightness_ext "Into the darkness"
    else
        dunstify -h string:x-dunst-stack-tag:brightness_ext -h int:value:"$new_brightness" \
                 "Monitor : $new_brightness" --icon="$HOME/.config/hypr/scripts/assets/brightness.svg"
    fi

    # Run change
    if [ "$isRunning" -eq 0 ]; then
        perform_brightness_action $new_brightness
    else
        while [ "$isRunning" -eq 1 ]; do
            sleep 1
            isRunning=$(grep -oP 'script_state =\s+\K\d+' "$state_file" || echo 0)
        done
        perform_brightness_action $new_brightness
    fi
else
    dunstify -h string:x-dunst-stack-tag:brightness_ext "Invalid argument." \
             "Please use a number (e.g., 5) or negative (e.g., -5)."
fi
