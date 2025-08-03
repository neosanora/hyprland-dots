#!/usr/bin/env bash

ICON_ON="/usr/share/icons/Adwaita/48x48/status/security-high.png"
ICON_OFF="/usr/share/icons/Adwaita/48x48/status/security-low.png"
NFT_CONF_DIR="$HOME/.config/nftables"
DEFAULT_CONF="$NFT_CONF_DIR/default.nft"
ACTIVE_FILE="$NFT_CONF_DIR/.active_filter"

mkdir -p "$NFT_CONF_DIR"

choose_filter() {
    rofi -dmenu -p "Pilih Filter Firewall" <<EOF
default
strict
gaming
web
EOF
}

if systemctl is-active --quiet nftables; then
    pkexec systemctl stop nftables
    notify-send "Firewall" "❌ Firewall dimatikan" -i "$ICON_OFF" --expire-time=2000
    rm -f "$ACTIVE_FILE"
else
    FILTER_NAME=$(choose_filter)
    [[ -z "$FILTER_NAME" ]] && FILTER_NAME="default"

    FILTER_FILE="$NFT_CONF_DIR/$FILTER_NAME.nft"
    if [[ -f "$FILTER_FILE" ]]; then
        pkexec nft -f "$FILTER_FILE"
    else
        pkexec nft -f "$DEFAULT_CONF"
    fi

    echo "$FILTER_NAME" > "$ACTIVE_FILE"
    pkexec systemctl start nftables
    notify-send "Firewall" "✅ Firewall aktif - Filter: $FILTER_NAME" -i "$ICON_ON" --expire-time=2000
fi
