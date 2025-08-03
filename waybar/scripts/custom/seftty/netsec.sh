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

    if nft list ruleset 2>/dev/null | grep -q "table inet filter"; then
        FILTER_NAME="default"
        if [[ -f "$ACTIVE_FILE" ]]; then
            FILTER_NAME=$(tr -d '\n\r' < "$ACTIVE_FILE")
        fi
        case "$FILTER_NAME" in
            vpn) ICON="🛡️[vpn]" ;;
            tor) ICON="🛡️[tor]" ;;
            *) ICON="🛡️[$FILTER_NAME]" ;;
        esac
        echo "{\"text\": \"$(escape_json "$ICON")\", \"tooltip\": \"Firewall aktif - Filter: $(escape_json "$FILTER_NAME")\"}"
    else
        echo '{"text": "❌", "tooltip": "Firewall mati"}'
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
        echo '{"text": "󪦇", "tooltip": "Tor tidak bisa dihubungi"}'
    else
        echo '{"text": "󪦇", "tooltip": "Tor mati / tidak digunakan"}'
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
