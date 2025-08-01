#!/usr/bin/env bash

if systemctl is-active --quiet tor; then
    pkexec systemctl stop tor
    notify-send "❌ Tor dimatikan"
else
    pkexec systemctl start tor
    notify-send "✅ Tor dinyalakan"
fi