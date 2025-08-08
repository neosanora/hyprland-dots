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

PACKAGES=$(checkupdates 2>/dev/null || true)

if [[ -z "$PACKAGES" ]]; then
  if command -v gum &>/dev/null; then
    gum confirm "✅ Sistem sudah up-to-date. Tutup?"
  else
    echo "✅ Sistem sudah up-to-date."
  fi
  exit 0
fi

FORMATTED=$(echo "$PACKAGES" | awk '{print $1 "\t" $2}')

echo "📦 Paket yang akan diupdate (jumlah: $(echo "$PACKAGES" | wc -l | tr -d ' ')):"
if command -v gum &>/dev/null; then
  echo -e "$FORMATTED" | gum table \
    --separator $'\t' \
    --columns "Paket,Versi Baru" \
    --widths 40,20 \
    --border rounded
else
  echo -e "$FORMATTED"
fi

if command -v gum &>/dev/null; then
  if gum confirm "Update sekarang?"; then
    sudo -v
    sudo pacman -Syu
  else
    echo "❌ Update dibatalkan."
  fi
else
  read -p "Update sekarang? (y/N) " ans
  if [[ "${ans,,}" == "y" ]]; then
    sudo -v
    sudo pacman -Syu
  else
    echo "❌ Update dibatalkan."
  fi
fi
