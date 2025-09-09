#!/usr/bin/env bash
# 🌈 Rainbow Border toggle berdasarkan file gamemode-enabled (dibalik logika)

set -euo pipefail
IFS=$'\n\t'

WATCH_DIR="$HOME/.config/ml4w/settings"
TRIGGER_FILE="gamemode-enabled"
INTERVAL=0.2
RAINBOW_PID=""

# --- Helpers ---
random_hex() {
    printf "0xff%06x" $((RANDOM * RANDOM % 16777216))
}

start_rainbow() {
    [[ -n "${RAINBOW_PID:-}" ]] && kill -0 "$RAINBOW_PID" 2>/dev/null && return
    (
        while true; do
            hyprctl keyword general:col.active_border \
                "$(random_hex)" "$(random_hex)" "$(random_hex)" "$(random_hex)" >/dev/null 2>&1
            sleep "$INTERVAL"
        done
    ) &
    RAINBOW_PID=$!
    echo "🌈 Rainbow border started"
}

stop_rainbow() {
    if [[ -n "${RAINBOW_PID:-}" ]]; then
        kill "$RAINBOW_PID" 2>/dev/null || true
        wait "$RAINBOW_PID" 2>/dev/null || true
        RAINBOW_PID=""
        echo "🌈 Rainbow border stopped"
    fi
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

# Pastikan folder ada
mkdir -p "$WATCH_DIR"

# Terapkan state awal
apply_state

# Monitor folder
inotifywait -m -q -e create,delete "$WATCH_DIR" | while read -r dir events filename; do
    if [[ "$filename" == "$TRIGGER_FILE" ]]; then
        apply_state
    fi
done