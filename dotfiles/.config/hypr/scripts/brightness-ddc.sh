#!/usr/bin/env bash

STEP=5
ICON="$HOME/.config/hypr/scripts/assets/brightness.svg"

# Ambil brightness dari monitor (0–100)
get_hw_brightness() {
    ddcutil getvcp 10 2>/dev/null \
        | awk -F'current value = ' '{print $2}' \
        | awk '{print $1}' \
        | tr -d ','
}

# Set brightness di monitor
apply_brightness() {
    local val=$1
    [ "$val" -lt 0 ] && val=0
    [ "$val" -gt 100 ] && val=100
    ddcutil setvcp 10 "$val" &>/dev/null
}

# Notifikasi slider
notify_brightness() {
    local val=$1
    notify-send -h int:value:"$val" \
                -h string:x-canonical-private-synchronous:brightness \
                -u low "󰃠 Brightness" "$val%" \
                --icon="$ICON"
}

case "$1" in
    up)
        current=$(get_hw_brightness)
        new=$((current + STEP))
        apply_brightness "$new"
        notify_brightness "$new"
        ;;
    down)
        current=$(get_hw_brightness)
        new=$((current - STEP))
        apply_brightness "$new"
        notify_brightness "$new"
        ;;
    set)
        val="$2"
        apply_brightness "$val"
        notify_brightness "$val"
        ;;
    get)
        get_hw_brightness
        ;;
    *)
        echo "Usage: $0 {up|down|set N|get}"
        ;;
esac
