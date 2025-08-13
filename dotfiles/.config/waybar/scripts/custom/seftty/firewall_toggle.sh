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
vpn
tor
EOF
}

FILTER_NAME=$(choose_filter)
[[ -z "$FILTER_NAME" ]] && exit 0  # batal kalau tidak pilih

FILTER_FILE="$NFT_CONF_DIR/$FILTER_NAME.nft"
[[ ! -f "$FILTER_FILE" ]] && FILTER_FILE="$DEFAULT_CONF"

# Ganti filter (flush ruleset dulu biar bersih)
pkexec nft flush ruleset
pkexec nft -f "$FILTER_FILE"

# Simpan nama filter aktif
echo "$FILTER_NAME" > "$ACTIVE_FILE"

notify-send "Firewall" "✅ Firewall aktif - Filter: $FILTER_NAME" -i "$ICON_ON" --expire-time=2000
