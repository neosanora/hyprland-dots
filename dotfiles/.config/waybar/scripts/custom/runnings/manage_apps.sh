#!/usr/bin/env bash

# Ambil daftar aplikasi yang sedang berjalan
apps=$(hyprctl clients -j | jq -r '.[] | "\(.class) | \(.title)"' | sort -u)

if [ -z "$apps" ]; then
    notify-send "No running apps"
    exit 0
fi

# Pilih aplikasi dari daftar
chosen=$(echo "$apps" | rofi -dmenu -i -p "Manage App")

[ -z "$chosen" ] && exit 0

# Ambil hanya nama class aplikasinya
app_class=$(echo "$chosen" | cut -d '|' -f 1 | xargs)

# Pilih aksi
action=$(printf "Focus\nKill" | rofi -dmenu -i -p "Action for $app_class")

if [ "$action" = "Focus" ]; then
    hyprctl dispatch focuswindow class:"$app_class"
elif [ "$action" = "Kill" ]; then
    pid=$(hyprctl clients -j | jq -r ".[] | select(.class==\"$app_class\") | .pid" | head -n 1)
    if [ -n "$pid" ]; then
        kill "$pid"
        notify-send "App closed" "$app_class has been killed."
    fi
fi
