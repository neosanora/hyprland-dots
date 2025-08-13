#!/usr/bin/env bash
# Auto Theme Script: Wallust + Matugen Integration
# -----------------------------------------------
# Fungsi: Ambil warna dominan dari wallpaper pakai Wallust, lalu olah jadi Material You pakai Matugen
# Output: Sinkron warna ke Waybar, GTK, Terminal, dsb.
# -----------------------------------------------

# === 1. Konfigurasi Awal ===
WALLPAPER_DIR="$HOME/Pictures/wallpapers"
CURRENT_WALLPAPER="$WALLPAPER_DIR/current.jpg" # ganti sesuai sistem kamu
WALLUST_BACKEND="haishoku" # opsi: haishoku, colorz, kmeans
MATUGEN_MODE="dark" # opsi: dark / light

# === 2. Ambil warna utama dari wallpaper pakai Wallust ===
if [[ ! -f "$CURRENT_WALLPAPER" ]]; then
    echo "❌ Wallpaper tidak ditemukan: $CURRENT_WALLPAPER"
    exit 1
fi

# Ambil warna dominan (HEX)
MAIN_COLOR=$(wallust run "$CURRENT_WALLPAPER" --backend "$WALLUST_BACKEND" --stdout | head -n 1)
if [[ -z "$MAIN_COLOR" ]]; then
    echo "❌ Gagal ambil warna dari Wallust"
    exit 1
fi

echo "🎨 Warna utama: $MAIN_COLOR"

# === 3. Generate palet Material You dari warna utama ===
matugen hex "$MAIN_COLOR" --mode "$MATUGEN_MODE"

# === 4. Terapkan ke Waybar & GTK ===
if pgrep -x "waybar" >/dev/null; then
    pkill -SIGUSR2 waybar
    echo "🔄 Waybar direload."
fi

# GTK (kalau pakai GNOME / GTK-based)
if command -v gsettings &>/dev/null; then
    if [[ "$MATUGEN_MODE" == "dark" ]]; then
        gsettings set org.gnome.desktop.interface color-scheme prefer-dark
    else
        gsettings set org.gnome.desktop.interface color-scheme prefer-light
    fi
    echo "🎯 GTK theme diupdate."
fi

# === 5. Notifikasi selesai ===
if command -v notify-send &>/dev/null; then
    notify-send "Wallust + Matugen" "Tema berhasil diperbarui berdasarkan wallpaper baru."
fi
