#!/usr/bin/env bash
# 🌈 Rainbow Border toggle dengan awareness gamemode + window.conf (low CPU + safe)
PIDFILE="/tmp/rainbow-border.pid"

WATCH_DIR="$HOME/.config/ml4w/settings"
TRIGGER_FILE="gamemode-enabled"

INTERVAL=0.2

# --- Configs ---
WINDOW_CONFS=(
    "$HOME/.config/hypr/conf/window.conf"
)

BLOCK_KEYWORDS=(
    "no-border"
    "gamemode"
    "border=0"
    "border:none"
)

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
        local pid
        pid=$(cat "$PIDFILE")
        if kill -0 "$pid" 2>/dev/null; then
            kill "$pid"
            wait "$pid" 2>/dev/null || true
        fi
        rm -f "$PIDFILE"
        echo "🌈 Rainbow border stopped"
    fi
    set_default_border
}

# --- State Manager ---
update_state() {
    # cek semua file conf
    for conf in "${WINDOW_CONFS[@]}"; do
        if [[ ! -s "$conf" ]]; then
            echo "🚫 $conf kosong atau hilang → rainbow border dimatikan."
            stop_rainbow
            return
        fi

        # cek semua keyword
        for key in "${BLOCK_KEYWORDS[@]}"; do
            if grep -q "$key" "$conf"; then
                echo "🚫 $conf mengandung '$key' → rainbow border dimatikan."
                stop_rainbow
                return
            fi
        done
    done

    # cek gamemode
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
    -e close_write "${WINDOW_CONFS[@]}" |
while read -r path events filename; do
    fullpath="$path$filename"
    if [[ "$filename" == "$TRIGGER_FILE" ]]; then
        update_state
    else
        for conf in "${WINDOW_CONFS[@]}"; do
            [[ "$fullpath" == "$conf" ]] && update_state
        done
    fi
done