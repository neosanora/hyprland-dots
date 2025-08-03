#!/usr/bin/env bash
# Script status Firewall + VPN + DNS + Tor
# Aman JSON untuk Waybar
# Tidak akan keluar kosong → selalu return JSON valid

MODE_FILE="/tmp/system_mode"

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

vpn_check() {
    VPN_IF=$(ip link | grep -E 'wg[0-9]|tun[0-9]|proton' | awk '{print $2}' | sed 's/://')

    if [[ -n "$VPN_IF" ]]; then
        VPN_IP=$(curl -s --max-time 2 https://ipinfo.io/org)
        if [[ "$VPN_IP" =~ "Proton" || "$VPN_IP" =~ "Mullvad" || "$VPN_IP" =~ "VPN" ]]; then
            echo '{"text": "🔒", "tooltip": "VPN aktif"}'
        else
            echo '{"text": "⚠️", "tooltip": "VPN interface ada tapi bukan dari VPN publik"}'
        fi
    else
        echo '{"text": "󪤅", "tooltip": "VPN tidak aktif"}'
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

tor_check() {
    result=$(curl --socks5-hostname 127.0.0.1:9050 \
                  --connect-timeout 2 --max-time 5 \
                  -s https://check.torproject.org/api/ip 2>/dev/null)

    if echo "$result" | grep -q '"IsTor":true'; then
        echo '{"text": "󪤎", "tooltip": "Tor aktif"}'
    elif [ -z "$result" ]; then
        echo '{"text": "󰋼", "tooltip": "Tor tidak bisa dihubungi"}'
    else
        echo '{"text": "", "tooltip": "Tor mati / tidak digunakan"}'
    fi
}

mode_check() {
    if [[ -f "$MODE_FILE" ]]; then
        MODE=$(cat "$MODE_FILE")
    else
        MODE="gaming"
    fi
    [[ "$MODE" == "privacy" ]] && echo '{"text": "󪥴", "tooltip": "Mode Privacy"}' || echo '{"text": "󪤳", "tooltip": "Mode Gaming"}'
}

# Argument handling
case "$1" in
    FW) firewall_check ;;
    VPN) vpn_check ;;
    DNS) dns_check ;;
    TOR) tor_check ;;
    MODE) mode_check ;;
    *) echo '{"text": "❓", "tooltip": "Argumen tidak valid"}' ;;
esac
