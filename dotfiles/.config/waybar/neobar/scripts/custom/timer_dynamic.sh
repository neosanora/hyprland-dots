#!/usr/bin/env bash

# 🍅 Pomodoro Timer (Bahasa Indonesia + Indikator Sesi)
# Lokasi: ~/.config/waybar/neobar/scripts/custom/timer_dynamic.sh

file=/tmp/waybar_pomodoro_timer
duration_file=/tmp/waybar_pomodoro_duration
mode_file=/tmp/waybar_pomodoro_mode
cycle_count_file=/tmp/waybar_pomodoro_cycle
signal_num=10  # samakan dengan "signal" di Waybar config

# Durasi default (detik)
WORK_TIME=$((25 * 60))
SHORT_BREAK=$((5 * 60))
LONG_BREAK=$((15 * 60))
CYCLES_BEFORE_LONG=4

# --- fungsi bantu ---
refresh_waybar() {
  pkill -RTMIN+$signal_num waybar 2>/dev/null
}

ding() {
  command -v canberra-gtk-play &>/dev/null && canberra-gtk-play -i complete &
}

notify_user() {
  local msg=$1
  notify-send "🍅 Pomodoro" "$msg"
}

start_timer() {
  local mode=$1
  local duration=$2
  local end_time=$(( $(date +%s) + duration ))
  echo "$end_time" > "$file"
  echo "$duration" > "$duration_file"
  echo "$mode" > "$mode_file"
  refresh_waybar
}

switch_mode() {
  local current=$(cat "$mode_file" 2>/dev/null)
  local cycle_count=$(cat "$cycle_count_file" 2>/dev/null)
  [[ -z $cycle_count ]] && cycle_count=0

  if [[ "$current" == "fokus" ]]; then
    ((cycle_count++))
    echo "$cycle_count" > "$cycle_count_file"
    if (( cycle_count % CYCLES_BEFORE_LONG == 0 )); then
      notify_user "Istirahat panjang dulu 🌙"
      ding
      start_timer "istirahat_panjang" $LONG_BREAK
    else
      notify_user "Waktunya istirahat sejenak 💧"
      ding
      start_timer "istirahat" $SHORT_BREAK
    fi
  else
    notify_user "Kembali fokus! 🔴"
    ding
    start_timer "fokus" $WORK_TIME
  fi
}

# --- perintah utama ---
case $1 in
  start)
    start_timer "fokus" $WORK_TIME
    echo 0 > "$cycle_count_file"
    notify_user "Sesi fokus dimulai — 25 menit!"
    ding
    ;;
  stop)
    rm -f "$file" "$duration_file" "$mode_file" "$cycle_count_file"
    notify_user "Pomodoro dihentikan."
    refresh_waybar
    ;;
  reset)
    rm -f "$file" "$duration_file" "$mode_file" "$cycle_count_file"
    start_timer "fokus" $WORK_TIME
    notify_user "Pomodoro direset — mulai sesi baru!"
    ding
    ;;
  switch)
    switch_mode
    ;;
  status)
    if [[ -f $file && -f $mode_file ]]; then
      end_time=$(cat "$file")
      duration=$(cat "$duration_file")
      mode=$(cat "$mode_file")
      now=$(date +%s)
      remaining=$(( end_time - now ))
      cycle_count=$(cat "$cycle_count_file" 2>/dev/null)
      [[ -z $cycle_count ]] && cycle_count=0

      if (( remaining <= 0 )); then
        switch_mode
        exit 0
      fi

      filled_blocks=$(( 10 - (remaining * 10 / duration) ))
      bar=$(printf "%-${filled_blocks}s" | tr ' ' '■')
      empty=$(printf "%-$((10 - filled_blocks))s" | tr ' ' ' ')
      case "$mode" in
        fokus) label="🔴 Fokus" ;;
        istirahat) label="💧 Istirahat" ;;
        istirahat_panjang) label="🌙 Istirahat Panjang" ;;
      esac

      # tampilkan sesi aktif
      session_info=" | Sesi $((cycle_count % CYCLES_BEFORE_LONG + 1))/$CYCLES_BEFORE_LONG"

      printf "%s %02d:%02d [%s%s]%s\n" "$label" $((remaining/60)) $((remaining%60)) "$bar" "$empty" "$session_info"
    else
      echo "🍅 --:-- [          ]"
    fi
    ;;
esac
