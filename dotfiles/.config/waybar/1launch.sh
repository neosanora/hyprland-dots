#!/bin/bash
#
# Waybar launcher (neobar version)
#

LOCKFILE="/tmp/waybar-launch.lock"
THEME_FILE="$HOME/.config/ml4w/settings/waybar-theme.sh"
DEFAULT_THEME="Default;default"
CONFIG_DIR="$HOME/.config/waybar/neobar/configs"
STYLE_DIR="$HOME/.config/waybar/neobar/styling"

# -----------------------------------------------------
# Prevent duplicate launches
# -----------------------------------------------------
exec 200>"$LOCKFILE"
flock -n 200 || exit 0

# -----------------------------------------------------
# Parse arguments
# -----------------------------------------------------
ACTION="start"
for arg in "$@"; do
    case $arg in
        --reload) ACTION="reload" ;;
        --stop)   ACTION="stop" ;;
        --theme=*) 
            echo "${arg#*=}" > "$THEME_FILE"
            ;;
    esac
done

# -----------------------------------------------------
# Manage Waybar processes
# -----------------------------------------------------
stop_waybar() {
    pkill waybar || true
    sleep 0.5
}

start_waybar() {
    # load theme
    if [[ -f "$THEME_FILE" ]]; then
        themestyle=$(cat "$THEME_FILE")
    else
        themestyle="$DEFAULT_THEME"
        echo "$themestyle" > "$THEME_FILE"
    fi

    IFS=";" read -ra arrThemes <<<"$themestyle"
    echo ":: Theme: ${arrThemes[0]}"

    CONFIG="$CONFIG_DIR/config"
    STYLE="$STYLE_DIR/style.css"

    waybar -c "$CONFIG" -s "$STYLE" >/dev/null 2>&1 &
    
# Explicitly release the lock (optional) -> flock releases on exit
flock -u 200
exec 200>&-
}

# -----------------------------------------------------
# Action handler
# -----------------------------------------------------
case $ACTION in
    start)  stop_waybar; start_waybar ;;
    reload) stop_waybar; start_waybar ;;
    stop)   stop_waybar ;;
esac