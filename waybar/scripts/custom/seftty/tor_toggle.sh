#!/usr/bin/env bash

ICON_ON="network-vpn"
ICON_OFF="network-offline"
PROXY_HOST="127.0.0.1"
PROXY_PORT="9050"

# Fungsi untuk tes IP publik
check_ip() {
    curl --socks5-hostname "$PROXY_HOST:$PROXY_PORT" -s https://ipinfo.io/country 2>/dev/null
}

# Fungsi set proxy (GNOME & lingkungan desktop yang kompatibel)
set_proxy() {
    gsettings set org.gnome.system.proxy mode 'manual'
    gsettings set org.gnome.system.proxy.socks host "$PROXY_HOST"
    gsettings set org.gnome.system.proxy.socks port "$PROXY_PORT"
}

# Fungsi hapus proxy
unset_proxy() {
    gsettings set org.gnome.system.proxy mode 'none'
}

# Toggle Tor
if systemctl is-active --quiet tor; then
    pkexec systemctl stop tor
    unset_proxy
    notify-send "Tor" "❌ Tor dimatikan" -i "$ICON_OFF" --expire-time=2000
else
    pkexec systemctl start tor
    sleep 3 # tunggu Tor siap
    set_proxy
    COUNTRY=$(check_ip)
    if [[ "$COUNTRY" != "ID" && "$COUNTRY" != "" ]]; then
        notify-send "Tor" "✅ Tor aktif - IP diubah ($COUNTRY)" -i "$ICON_ON" --expire-time=3000
    else
        notify-send "Tor" "⚠️ Tor aktif tapi IP belum berubah" -i "$ICON_OFF" --expire-time=3000
    fi
fi
