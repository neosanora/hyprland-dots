#!/usr/bin/env bash
# Script status Firewall + VPN + DNS + Tor
# Aman JSON untuk Waybar
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
            *)       echo "🛡️" ;;  # fallback
        esac
    }

    if [[ -f "$ACTIVE_FILE" ]]; then
        # Firewall aktif berdasarkan file
        FILTER_NAME=$(head -n 1 "$ACTIVE_FILE" | tr -d '\n\r')
        [[ -z "$FILTER_NAME" ]] && FILTER_NAME="default"

        ICON=$(get_icon_for_filter "$FILTER_NAME")
        TOOLTIP="Firewall aktif - Filter: $FILTER_NAME"
        echo "{\"text\": \"$ICON\", \"tooltip\": \"$(escape_json "$TOOLTIP")\"}"

    elif nft list ruleset 2>/dev/null | grep -qE "table (inet|ip|ip6) .*filter"; then
        # Firewall aktif tapi tidak ada file filter
        FILTER_NAME="default"
        ICON=$(get_icon_for_filter "$FILTER_NAME")
        TOOLTIP="Firewall aktif - Filter: $FILTER_NAME"
        echo "{\"text\": \"$ICON\", \"tooltip\": \"$(escape_json "$TOOLTIP")\"}"

    else
        # Firewall mati
        ICON="❌"
        TOOLTIP="⚠️ Firewall mati"
        echo "{\"text\": \"$ICON\", \"tooltip\": \"$(escape_json "$TOOLTIP")\"}"
    fi
}
dns_check() {
    DNS_SERVERS=$(grep -E '^nameserver' /etc/resolv.conf | awk '{print $2}' | paste -sd ', ')
    if [[ -n "$DNS_SERVERS" ]]; then
        TOOLTIP=$(escape_json "$DNS_SERVERS")
        echo "{\"text\": \"🌐\", \"tooltip\": \"$TOOLTIP\"}"
    else
        echo '{"text": "󪤌", "tooltip": "Tidak ada DNS"}'
    fi
}
# Argument handling
case "$1" in
    FW) firewall_check ;;
    DNS) dns_check ;;
    *) echo '{"text": "❓", "tooltip": "Argumen tidak valid"}' ;;
esac
