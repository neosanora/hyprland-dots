#!/usr/bin/env bash
set -euo pipefail

ICON_ON="󪤎"  # ikon tor aktif (Nerd Font)
ICON_OFF=""  # ikon tor mati

set_proxy() {
    export ALL_PROXY="socks5h://127.0.0.1:9050"
    export HTTP_PROXY="http://127.0.0.1:9050"
    export HTTPS_PROXY="http://127.0.0.1:9050"
}

unset_proxy() {
    unset ALL_PROXY HTTP_PROXY HTTPS_PROXY
}

if systemctl is-active --quiet tor; then
    if pkexec systemctl stop tor; then
        unset_proxy
        notify-send "Tor" "❌ Tor dimatikan" -i "$ICON_OFF" --expire-time=2000
    else
        # Dibatalkan atau gagal
        exit 1
    fi
else
    if pkexec systemctl start tor; then
        sleep 2
        if systemctl is-active --quiet tor; then
            set_proxy
            notify-send "Tor" "✅ Tor diaktifkan" -i "$ICON_ON" --expire-time=2000
        else
            notify-send -u critical "Tor" "⚠️ Gagal mengaktifkan Tor" -i "$ICON_OFF"
        fi
    else
        # Dibatalkan atau gagal
        exit 1
    fi
fi
