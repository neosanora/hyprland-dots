#!/usr/bin/env bash
set -euo pipefail

if [ -t 1 ]; then
  trap 'read -r -p "Tekan ENTER untuk menutup..."' EXIT
fi

if ! command -v checkupdates &>/dev/null; then
  echo "❌ pacman-contrib belum terinstall."
  echo "Jalankan: sudo pacman -S pacman-contrib"
  exit 1
fi

if ! command -v gum &>/dev/null; then
  echo "❌ gum belum terinstall."
  echo "Jalankan: sudo pacman -S gum"
  exit 1
fi

PACKAGES=$(checkupdates 2>/dev/null || true)

if [[ -z "$PACKAGES" ]]; then
  gum confirm "✅ Sistem sudah up-to-date. Tutup?" && exit 0
  exit 0
fi

# Format paket dan versi baru
FORMATTED=$(echo "$PACKAGES" | awk '{print $1 "\t" $2}')
PKG_LIST=()
while IFS= read -r line; do
  # Ambil nama paket saja, simpan di array
  PKG_LIST+=("$(echo "$line" | awk '{print $1}')")
done <<< "$PACKAGES"

echo "📦 Paket yang akan diupdate (jumlah: ${#PKG_LIST[@]}):"
echo -e "$FORMATTED" | gum table --separator $'\t' --columns "Paket,Versi Baru" --widths 40,20 --border rounded

# Menu pilihan mode update
CHOICE=$(gum choose --cursor.foreground 212 --limit 1 "Update semua paket" "Pilih paket secara manual" "Batal")

case "$CHOICE" in
  "Update semua paket")
    sudo -v
    sudo pacman -Syu
    echo "✅ Update semua paket selesai."
    ;;
  "Pilih paket secara manual")
    SELECTED=$(printf '%s\n' "${PKG_LIST[@]}" | gum choose --no-limit --cursor.foreground 212 --height 10 --header "Pilih paket yang ingin diupdate (gunakan space untuk pilih):")
    if [[ -z "$SELECTED" ]]; then
      echo "❌ Tidak ada paket yang dipilih. Update dibatalkan."
    else
      sudo -v
      # update paket yang dipilih saja
      sudo pacman -S --needed $SELECTED
      echo "✅ Update paket terpilih selesai."
    fi
    ;;
  "Batal")
    echo "❌ Update dibatalkan."
    ;;
  *)
    echo "❌ Pilihan tidak valid."
    ;;
esac
