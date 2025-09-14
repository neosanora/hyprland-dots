#!/usr/bin/env bash
# Script status Firewall + VPN + DNS + Tor
# Output JSON aman untuk Waybar
# Tidak akan keluar kosong → selalu return JSON valid

# Fungsi escape untuk tooltip supaya JSON aman
escape_json() {
    echo "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

firewall_check() {
    ACTIVE_FILE="$HOME/.config/nftables/.active_filter"

    # Mapping filter ke icon
    get_icon_for_filter() {
        case "$1" in
            default) echo "󰞉" ;;  # default
            strict)  echo "󱛆" ;;  # strict mode
            gaming)  echo "" ;;  # gaming
            web)     echo "󰮡" ;;  # web mode
            vpn)     echo "󱚿" ;;  # vpn
            tor)     echo "󰯚" ;;  # tor
            *)       echo "󰒃" ;;  # fallback (shield)
        esac
    }

    # Cek apakah nftables terpasang
    if ! command -v nft &>/dev/null; then
        ICON="󰅗"
        TOOLTIP="❌ nftables belum terpasang"
        echo "{\"text\": \"$ICON\", \"tooltip\": \"$(escape_json "$TOOLTIP")\"}"
        return
    fi

    # Cek status service nftables (jika systemd ada)
    if command -v systemctl &>/dev/null; then
        if ! systemctl is-active --quiet nftables; then
            ICON="󰅗"
            TOOLTIP="⚠️ nftables terpasang tapi servicenya tidak berjalan"
            echo "{\"text\": \"$ICON\", \"tooltip\": \"$(escape_json "$TOOLTIP")\"}"
            return
        fi
    fi

    # Kalau ada file aktif → pakai itu
    if [[ -f "$ACTIVE_FILE" ]]; then
        FILTER_NAME=$(head -n 1 "$ACTIVE_FILE" | tr -d '\n\r')
        [[ -z "$FILTER_NAME" ]] && FILTER_NAME="default"

        ICON=$(get_icon_for_filter "$FILTER_NAME")
        RULES_COUNT=$(nft list ruleset 2>/dev/null | grep -c 'chain')
        TOOLTIP="Firewall aktif - Filter: $FILTER_NAME ($RULES_COUNT chains)"
        echo "{\"text\": \"$ICON\", \"tooltip\": \"$(escape_json "$TOOLTIP")\"}"

    # Kalau ruleset ada tapi file gak ada → fallback default
    elif nft list ruleset 2>/dev/null | grep -qE "table (inet|ip|ip6) .*filter"; then
        FILTER_NAME="default"
        ICON=$(get_icon_for_filter "$FILTER_NAME")
        RULES_COUNT=$(nft list ruleset 2>/dev/null | grep -c 'chain')
        TOOLTIP="Firewall aktif - Filter: $FILTER_NAME ($RULES_COUNT chains)"
        echo "{\"text\": \"$ICON\", \"tooltip\": \"$(escape_json "$TOOLTIP")\"}"

    else
        ICON="󰅗"
        TOOLTIP="⚠️ Firewall mati (tidak ada ruleset)"
        echo "{\"text\": \"$ICON\", \"tooltip\": \"$(escape_json "$TOOLTIP")\"}"
    fi
}

dns_check() {
    DNS_SERVERS=$(grep -E '^\s*nameserver\s+' /etc/resolv.conf | awk '{print $2}' | paste -sd ', ')
    if [[ -n "$DNS_SERVERS" ]]; then
        TOOLTIP=$(escape_json "$DNS_SERVERS")
        echo "{\"text\": \"󰖟\", \"tooltip\": \"$TOOLTIP\"}"  # globe nerdfont
    else
        echo '{"text": "󰅗", "tooltip": "Tidak ada DNS"}'
    fi
}

# Argument handling
case "$1" in
    FW) firewall_check ;;
    DNS) dns_check ;;
    *) echo '{"text": "❓", "tooltip": "Argumen tidak valid"}' ;;
esac