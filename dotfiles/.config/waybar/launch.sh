#!/bin/bash
#                    __
#  _    _____ ___ __/ /  ___ _____
# | |/|/ / _ `/ // / _ \/ _ `/ __/
# |__,__/\_,_/\_, /_.__/\_,_/_/
#            /___/
#
# Waybar Launcher with Theme Manager & Neobar Switcher
#

# -----------------------------------------------------
# Prevent duplicate launches
# -----------------------------------------------------
exec 200>/tmp/waybar-launch.lock
flock -n 200 || exit 0

# -----------------------------------------------------
# Kill existing waybar
# -----------------------------------------------------
pkill waybar 2>/dev/null || true
sleep 0.5

# -----------------------------------------------------
# Default theme
# -----------------------------------------------------
DEFAULT_THEME="/ml4w-modern;/ml4w-modern/default"

# -----------------------------------------------------
# Remove incompatible/legacy themes
# -----------------------------------------------------
SETTINGS_DIR="$HOME/.config/ml4w/settings"
THEMES_DIR="$HOME/.config/waybar/themes"

if [ -f "$SETTINGS_DIR/waybar-theme.sh" ]; then
    themestyle=$(cat "$SETTINGS_DIR/waybar-theme.sh")
    case "$themestyle" in
        "/ml4w-modern;/ml4w-modern/light" | \
        "/ml4w-modern;/ml4w-modern/dark"  | \
        "/ml4w;/ml4w/light"               | \
        "/ml4w;/ml4w/dark")
            echo "$DEFAULT_THEME" > "$SETTINGS_DIR/waybar-theme.sh"
            ;;
    esac

    rm -rf "$THEMES_DIR/ml4w-modern/light" \
           "$THEMES_DIR/ml4w-modern/dark" \
           "$THEMES_DIR/ml4w-modern/colored" \
           "$THEMES_DIR/ml4w/light" \
           "$THEMES_DIR/ml4w/dark"
fi

# -----------------------------------------------------
# Load current theme
# -----------------------------------------------------
if [ -f "$SETTINGS_DIR/waybar-theme.sh" ]; then
    themestyle=$(cat "$SETTINGS_DIR/waybar-theme.sh")
else
    echo "$DEFAULT_THEME" > "$SETTINGS_DIR/waybar-theme.sh"
    themestyle=$DEFAULT_THEME
fi

IFS=';' read -ra arrThemes <<< "$themestyle"
themeFolder="${arrThemes[0]}"
themeVariant="${arrThemes[1]}"

echo ":: Current Theme: $themeFolder"

if [ ! -f "$THEMES_DIR/${themeVariant}/style.css" ]; then
    themestyle=$DEFAULT_THEME
    IFS=';' read -ra arrThemes <<< "$themestyle"
    themeFolder="${arrThemes[0]}"
    themeVariant="${arrThemes[1]}"
fi

# -----------------------------------------------------
# Select config & style files
# -----------------------------------------------------
config_file="config"
style_file="style.css"

[ -f "$THEMES_DIR/${themeFolder}/config-custom" ] && config_file="config-custom"
[ -f "$THEMES_DIR/${themeVariant}/style-custom.css" ] && style_file="style-custom.css"

# -----------------------------------------------------
# Launch Waybar (with Neobar switcher)
# -----------------------------------------------------
if [ ! -f "$SETTINGS_DIR/waybar-disabled" ]; then
    HYPRLAND_SIGNATURE=$(hyprctl instances -j | jq -r '.[0].instance')

    if [ -f "$SETTINGS_DIR/waybar-use-neobar" ]; then
        echo ":: Using Neobar"
        CONFIG="$HOME/.config/waybar/neobar/configs/config"
        STYLE="$HOME/.config/waybar/neobar/styling/style.css"

        HYPRLAND_INSTANCE_SIGNATURE="$HYPRLAND_SIGNATURE" waybar \
            -c "$CONFIG" -s "$STYLE" &
    elif [ -f "$SETTINGS_DIR/waybar-use-cachybar" ]; then
        echo ":: Using CachyOS Theme"
        CONFIG="$HOME/.config/waybar/cachybar/config"
        STYLE="$HOME/.config/waybar/cachybar/style.css"

        HYPRLAND_INSTANCE_SIGNATURE="$HYPRLAND_SIGNATURE" waybar \
            -c "$CONFIG" -s "$STYLE" &
    elif [ -f "$SETTINGS_DIR/waybar-use-eww" ]; then
        echo ":: Using Eww"
        $HOME/.config/eww/launch.sh
    else
        echo ":: Using Theme Config"
        HYPRLAND_INSTANCE_SIGNATURE="$HYPRLAND_SIGNATURE" waybar \
            -c "$THEMES_DIR/${themeFolder}/$config_file" \
            -s "$THEMES_DIR/${themeVariant}/$style_file" &
    fi
else
    echo ":: Waybar disabled"
fi

# -----------------------------------------------------
# Release lock
# -----------------------------------------------------
flock -u 200
exec 200>&-
