#!/usr/bin/env bash

# Cek apakah Tor terinstall
if ! command -v tor &>/dev/null; then
    notify-send "❌ Tor tidak ditemukan" "Silakan install Tor terlebih dahulu"
    exit 1
fi

# Cek apakah service Tor ada di systemd
if ! systemctl list-unit-files | grep -q "^tor.service"; then
    notify-send "❌ Service Tor tidak ditemukan" "Pastikan Tor sudah terinstall dengan dukungan systemd"
    exit 1
fi

ICON_ON="network-vpn"
ICON_OFF="network-offline"

# Toggle Tor service
if systemctl is-active --quiet tor; then
    pkexec systemctl stop tor
    notify-send "Tor" "❌ Tor dimatikan" -i "$ICON_OFF" --expire-time=2000
else
    pkexec systemctl start tor
    notify-send "Tor" "✅ Tor dinyalakan" -i "$ICON_ON" --expire-time=2000
fi
