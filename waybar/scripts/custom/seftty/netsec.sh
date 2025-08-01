#!/usr/bin/env bash
# Script status Firewall + VPN + DNS + Tor
# Pastikan nftables & curl terinstall
# Untuk sudo tanpa password: atur di sudoers

MODE_FILE="/tmp/system_mode"

firewall_check() {
    # Cek nftables
    if command -v nft >/dev/null 2>&1 && nft list ruleset 2>/dev/null | grep -q "table inet filter"; then
        echo "🛡️"
        return
    fi

    # Cek firewalld
    if command -v firewall-cmd >/dev/null 2>&1 && firewall-cmd --state 2>/dev/null | grep -q "running"; then
        echo "🛡️"
        return
    fi

    # Cek ufw
    if command -v ufw >/dev/null 2>&1 && ufw status 2>/dev/null | grep -q "Status: active"; then
        echo "🛡️"
        return
    fi

    # Cek iptables
    if command -v iptables >/dev/null 2>&1 && iptables -L 2>/dev/null | grep -q "Chain"; then
        echo "🛡️"
        return
    fi

    # Kalau tidak ada yang aktif
    echo "󪥳"
}

vpn_check() {
    # Cari interface VPN umum: WireGuard, OpenVPN, ProtonVPN
    VPN_IF=$(ip link | grep -E 'wg[0-9]|tun[0-9]|proton' | awk '{print $2}' | sed 's/://')

    if [[ -n "$VPN_IF" ]]; then
        # Cek IP publik
        VPN_IP=$(curl -s --max-time 2 https://ipinfo.io/org)
        if [[ "$VPN_IP" =~ "Proton" || "$VPN_IP" =~ "Mullvad" || "$VPN_IP" =~ "VPN" ]]; then
            echo "🔒" # VPN aktif
        else
            echo "⚠️" # VPN interface ada tapi bukan dari VPN publik
        fi
    else
        echo "󪤅" # VPN tidak aktif
    fi
}

# DNS check
dns_check() {
    DNS_SERVERS=$(grep -E '^nameserver' /etc/resolv.conf | awk '{print $2}' | tr '\n' ',' | sed 's/,$//')
    if [[ -n "$DNS_SERVERS" ]]; then
        echo "🌐 $DNS_SERVERS"
    else
        echo "󪤌"
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
        echo "󪤎"  # Tor aktif

    # Kalau curl gagal total (Tor service mati atau port salah)
    elif [ -z "$result" ]; then
        echo "󪦇"  # Tor tidak bisa dihubungi

    # Kalau API nyala tapi bukan lewat Tor
    else
        echo "󪦇"  # Tor mati / tidak digunakan
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
