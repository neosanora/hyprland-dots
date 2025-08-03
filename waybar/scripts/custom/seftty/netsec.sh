#!/usr/bin/env bash
# Script status Firewall + VPN + DNS + Tor
# Pastikan nftables & curl terinstall
# Untuk sudo tanpa password: atur di sudoers

MODE_FILE="/tmp/system_mode"

firewall_check() {
    ACTIVE_FILE="$HOME/.config/nftables/.active_filter"

    # Pastikan nftables terpasang
    if ! command -v nft >/dev/null 2>&1; then
        echo '{"text": "❌", "tooltip": "nftables tidak terpasang"}'
        exit 1
    fi

    # Cek service aktif atau tidak
    if ! systemctl is-active --quiet nftables; then
        echo '{"text": "❌", "tooltip": "Firewall mati"}'
        exit 0
    fi

    # Service aktif → cek rules
    if nft list ruleset 2>/dev/null | grep -q "table inet filter"; then
        # Ada table inet filter → hijau
        if [[ -f "$ACTIVE_FILE" ]]; then
            FILTER_NAME=$(cat "$ACTIVE_FILE")
        else
            FILTER_NAME="default"
        fi
        echo "{\"text\": \"🛡️[$FILTER_NAME]\", \"tooltip\": \"Firewall aktif - Filter: $FILTER_NAME\"}"
    else
        # Service aktif tapi rules kosong → kuning
        echo '{"text": "⚠️", "tooltip": "Firewall aktif tapi rules kosong"}'
    fi

}

vpn_check() {
    # Cari interface VPN umum: WireGuard, OpenVPN, ProtonVPN
    VPN_IF=$(ip link | grep -E 'wg[0-9]|tun[0-9]|proton' | awk '{print $2}' | sed 's/://')

    if [[ -n "$VPN_IF" ]]; then
        # Cek IP publik
        VPN_IP=$(curl -s --max-time 2 https://ipinfo.io/org)
        if [[ "$VPN_IP" =~ "Proton" || "$VPN_IP" =~ "Mullvad" || "$VPN_IP" =~ "VPN" ]]; then
            echo "{\"text\": \"🔒\", \"tooltip\": \"VPN aktif\"}"

        else
            echo "{\"text\": \"⚠️\", \"tooltip\": \"VPN interface ada tapi bukan dari VPN publik\"}"
        fi
    else
        echo "{\"text\": \"󪤅\", \"tooltip\": \"Tor mati /VPN tidak aktif\"}"

    fi
}


dns_check() {
    DNS_SERVERS=$(grep -E '^nameserver' /etc/resolv.conf | awk '{print $2}' | paste -sd ', ')
    if [[ -n "$DNS_SERVERS" ]]; then
        # Escape karakter khusus supaya JSON aman
        TOOLTIP=$(echo "$DNS_SERVERS" | sed 's/"/\\"/g')
        echo "{\"text\": \"🌐\", \"tooltip\": \"$TOOLTIP\"}"
    else
        echo "{\"text\": \"󪤌\", \"tooltip\": \"Tidak ada DNS\"}"
    fi
}


# Tor check
tor_check() {
    # Tes koneksi Tor lewat API JSON
    local result
    result=$(curl --socks5-hostname 127.0.0.1:9050 \
                  --connect-timeout 2 --max-time 5 \
                  -s https://check.torproject.org/api/ip 2>/dev/null)

    # Kalau API balas "IsTor":true
    if echo "$result" | grep -q '"IsTor":true'; then
        echo "{\"text\": \"󪤎\", \"tooltip\": \"ON\"}"
    # Kalau curl gagal total (Tor service mati atau port salah)
    elif [ -z "$result" ]; then
        echo "{\"text\": \"󪦇\", \"tooltip\": \"Tor tidak bisa dihubungi\"}"

    # Kalau API nyala tapi bukan lewat Tor
    else
        echo "{\"text\": \"󪦇\", \"tooltip\": \"Tor mati / tidak digunakan\"}"

    fi
}


# Mode check
mode_check() {
    if [[ -f "$MODE_FILE" ]]; then
        MODE=$(cat "$MODE_FILE")
    else
        MODE="gaming"
    fi
    [[ "$MODE" == "privacy" ]] && echo "󪥴" || echo "󪤳"
}

# Argument handling
case "$1" in
    FW) firewall_check ;;
    VPN) vpn_check ;;
    DNS) dns_check ;;
    TOR) tor_check ;;
    MODE) mode_check ;;
    *) exit ;;
esac
