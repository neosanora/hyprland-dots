#!/usr/bin/env bash

STEP=3
ICON_MAX="$HOME/.config/hypr/scripts/assets/volume-max.svg"
ICON_MUTED="$HOME/.config/hypr/scripts/assets/muted.svg"
ICON_ALERT="$HOME/.config/hypr/scripts/assets/alert.svg"

# Ambil volume sekarang
get_volume() {
    pamixer --get-volume
}

# Ambil status mute
is_muted() {
    pamixer --get-mute
}

# Set notifikasi volume
notify_volume() {
    local vol=$1
    local muted=$2
    local icon="$ICON_MAX"
    local title="󰕾 Volume"

    if [ "$muted" = "true" ] || [ "$vol" -eq 0 ]; then
        title="󰝟 Muted"
        icon="$ICON_MUTED"
        vol=0
    elif [ "$vol" -ge 100 ]; then
        title=" Full Volume"
        icon="$ICON_MAX"
        vol=100
    fi

    notify-send -h int:value:"$vol" \
                -h string:x-canonical-private-synchronous:volume \
                -u low "$title" "$vol%" \
                --icon="$icon"
}

case "$1" in
    I)
        pamixer -i "$STEP"
        ;;
    D)
        pamixer -d "$STEP"
        ;;
    T)
        pamixer -t
        ;;
    *)
        notify-send "Please use correct args (I|D|T)" --icon="$ICON_ALERT"
        exit 1
        ;;
esac

volume=$(get_volume)
muted=$(is_muted)
notify_volume "$volume" "$muted"
