#!/usr/bin/env bash
# Script status Firewall + VPN + DNS + Tor
# Pastikan nftables & curl terinstall
# Untuk sudo tanpa password: atur di sudoers

MODE_FILE="/tmp/system_mode"

# Firewall check
firewall_check() {
    if sudo nft list ruleset 2>/dev/null | grep -q "table inet filter"; then
        echo "🛡️"
    else
        echo "󪥳"
    fi
}

# VPN check + IP
vpn_check() {
    VPN_IF=$(ip link | grep -E 'wg0|tun0' | awk '{print $2}' | sed 's/://')
    if [[ -n "$VPN_IF" ]]; then
        VPN_IP=$(curl -s --max-time 2 https://ipinfo.io/ip)
        echo "🔒 $VPN_IP"
    else
        echo "󪤅"
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
    if curl --socks5-hostname 127.0.0.1:9050 -s https://check.torproject.org/ | grep -q "Congratulations"; then
        echo "󪤎"
    else
        echo "󪦇"
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
