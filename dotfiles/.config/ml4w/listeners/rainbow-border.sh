#!/usr/bin/env bash
# 🌈 Rainbow Border toggle berdasarkan file gamemode-enabled (dibalik logika)


WATCH_DIR="$HOME/.config/ml4w/settings"
TRIGGER_FILE="gamemode-enabled"
INTERVAL=0.2
PIDFILE="/tmp/rainbow-border.pid"

# --- Helpers ---
random_hex() {
    printf "0xff%06x" "$((RANDOM % 16777216))"
}

set_default_border() {
    hyprctl keyword general:col.active_border \
        "0xffffffff" "0xffffffff" "0xffffffff" "0xffffffff" >/dev/null 2>&1
}

start_rainbow() {
    # Cek kalau sudah ada PID lama
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

apply_state() {
    if [[ -f "$WATCH_DIR/$TRIGGER_FILE" ]]; then
        # Kalau file ada → stop rainbow
        stop_rainbow
    else
        # Kalau file tidak ada → start rainbow
        start_rainbow
    fi
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

# --- Terapkan state awal ---
apply_state

# --- Monitor folder ---
inotifywait -m -q -e create,delete "$WATCH_DIR" | while read -r dir events filename; do
    if [[ "$filename" == "$TRIGGER_FILE" ]]; then
        apply_state
    fi
done