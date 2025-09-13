#!/usr/bin/env bash
# 🌈 Rainbow Border toggle dengan awareness gamemode + window.conf (low CPU + safe)

WATCH_DIR="$HOME/.config/ml4w/settings"
TRIGGER_FILE="gamemode-enabled"
INTERVAL=0.2
PIDFILE="/tmp/rainbow-border.pid"

WINDOW_CONF="$HOME/.config/hypr/conf/window.conf"

# --- Helpers ---
random_hex() {
    printf "0xff%06x" "$((RANDOM % 16777216))"
}

set_default_border() {
    hyprctl keyword general:col.active_border \
        "0xffffffff" "0xffffffff" "0xffffffff" "0xffffffff" >/dev/null 2>&1
}

start_rainbow() {
    if [[ -f "$PIDFILE" ]] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
        return
    fi
    (
        while true; do
            hyprctl keyword general:col.active_border \
                "$(random_hex)" "$(random_hex)" "$(random_hex)" "$(random_hex)" >/dev/null 2>&1
            sleep "$INTERVAL"
        done
    ) &
    echo $! > "$PIDFILE"
    echo "🌈 Rainbow border started (PID=$(cat "$PIDFILE"))"
}

stop_rainbow() {
    if [[ -f "$PIDFILE" ]]; then
        kill "$(cat "$PIDFILE")" 2>/dev/null || true
        wait "$(cat "$PIDFILE")" 2>/dev/null || true
        rm -f "$PIDFILE"
        echo "🌈 Rainbow border stopped"
    fi
    set_default_border
}

# --- State Manager ---
update_state() {
    if [[ ! -s "$WINDOW_CONF" ]]; then
        # File tidak ada / kosong
        echo "🚫 window.conf kosong atau hilang → rainbow border dimatikan."
        stop_rainbow
        return
    fi

    if grep -q "no-border" "$WINDOW_CONF"; then
        echo "🚫 window.conf mengandung 'no-border' → rainbow border dimatikan."
        stop_rainbow
        return
    fi

    if [[ -f "$WATCH_DIR/$TRIGGER_FILE" ]]; then
        echo "🎮 gamemode aktif → rainbow border dimatikan."
        stop_rainbow
        return
    fi

    echo "✅ Kondisi normal → rainbow border aktif."
    start_rainbow
}

cleanup() {
    stop_rainbow
    exit 0
}
trap cleanup EXIT INT TERM

# --- Cek dependensi ---
for cmd in inotifywait hyprctl; do
    command -v "$cmd" >/dev/null 2>&1 || {
        echo "❌ Missing required command: $cmd"
        exit 1
    }
done

# --- Apply initial state ---
update_state

# --- Monitor window.conf + gamemode-enabled ---
inotifywait -m -q \
    -e create,delete "$WATCH_DIR" \
    -e close_write "$WINDOW_CONF" |
while read -r path events filename; do
    if [[ "$path$filename" == "$WINDOW_CONF" ]] || [[ "$filename" == "$TRIGGER_FILE" ]]; then
        update_state
    fi
done