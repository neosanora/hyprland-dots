#!/usr/bin/env bash

ICON_ON="network-vpn"
ICON_OFF="network-offline"

# Fungsi set proxy (GNOME)
set_proxy() {
    gsettings set org.gnome.system.proxy mode 'manual'
    gsettings set org.gnome.system.proxy.socks host '127.0.0.1'
    gsettings set org.gnome.system.proxy.socks port 9050
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
    notify-send "Tor" "✅ Tor diaktifkan" -i "$ICON_ON" --expire-time=2000
fi
