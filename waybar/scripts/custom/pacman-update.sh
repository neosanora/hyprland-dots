#!/usr/bin/env bash
set -euo pipefail

# Warna ANSI
YELLOW="\033[33m"
RED="\033[31m"
GREEN="\033[32m"
RESET="\033[0m"

# Ikon kategori
ICON_SYSTEM="🖥"
ICON_DRIVER="🎮"
ICON_PACKAGE="📦"

error_exit() {
  echo "❌ $1" >&2
  exit 1
}

check_command() {
  if ! command -v "$1" &>/dev/null; then
    error_exit "$1 belum terinstall. Jalankan: sudo pacman -S $1"
  fi
}

get_package_category() {
  local pkg="$1"
  local pkg_lower="${pkg,,}"
  local system_pkgs=("linux" "glibc" "systemd" "bash" "pacman" "coreutils" "binutils" "filesystem" "gcc" "linux-firmware")
  local driver_keywords=("nvidia" "xf86-video" "mesa" "vulkan" "radeon" "broadcom-wl" "amdgpu")

  for spkg in "${system_pkgs[@]}"; do
    if [[ "$pkg_lower" == "$spkg" || "$pkg_lower" == "$spkg"* ]]; then
      echo "System"
      return
    fi
  done

  for dkw in "${driver_keywords[@]}"; do
    if [[ "$pkg_lower" == *"$dkw"* ]]; then
      echo "Driver"
      return
    fi
  done

  echo "Package"
}

color_for_category() {
  case "$1" in
    System)  echo -e "${YELLOW}${ICON_SYSTEM} $2${RESET}" ;;
    Driver)  echo -e "${RED}${ICON_DRIVER} $2${RESET}" ;;
    Package) echo -e "${GREEN}${ICON_PACKAGE} $2${RESET}" ;;
    *)       echo "$2" ;;
  esac
}

update_all_with_retry() {
  sudo -v
  echo "🔄 Mulai update semua paket..."
  until sudo pacman -Syu; do
    echo "⚠️ Update gagal, cek koneksi. Ulang dalam 5 detik..."
    sleep 5
  done
  echo "✅ Update semua paket selesai."
}

update_selected_with_retry() {
  local -a selected_pkgs=("$@")
  sudo -v
  echo "🔄 Mengupdate paket terpilih..."
  until sudo pacman -S --needed "${selected_pkgs[@]}"; do
    echo "⚠️ Update paket gagal, cek koneksi. Ulang dalam 5 detik..."
    sleep 5
  done
  echo "✅ Update paket terpilih selesai."
}

safe_table() {
  if ! gum table "$@" 2>/dev/null; then
    column -t -s "$3"
  fi
}

show_installed_packages() {
  echo "📋 Daftar paket terinstall:"
  pacman -Q | safe_table --columns "Paket,Versi" --separator ' ' --widths 40,20 --border rounded
  echo
}

show_installed_by_size() {
  echo "📏 Menghitung ukuran paket, tunggu sebentar..."
  pacman -Qi | awk '
    /^Name/ {name=$3}
    /^Installed Size/ {
      size=$4
      unit=$5
      if (unit=="MiB") {size_kb=size*1024}
      else if (unit=="GiB") {size_kb=size*1024*1024}
      else if (unit=="KiB") {size_kb=size}
      else {size_kb=0}
      print name "\t" size "\t" unit "\t" size_kb
    }
  ' | sort -k4 -nr | awk -F'\t' '{printf "%-40s %-10s %s\n", $1, $2, $3}' | safe_table --columns "Paket,Ukuran,Unit" --separator ' ' --widths 40,10,10 --border rounded
  echo
}

setup_exit_trap() {
  if [ -t 1 ]; then
    trap 'read -r -p "Tekan ENTER untuk menutup..."' EXIT
  fi
}

main() {
  setup_exit_trap
  check_command checkupdates
  check_command gum
  check_command pacman

  while true; do
    PACKAGES=$(checkupdates 2>/dev/null || true)
    if [[ -z "$PACKAGES" ]]; then
      gum confirm "✅ Sistem sudah up-to-date. Tutup?" && exit 0
      echo "Tidak ada paket untuk diupdate."
      PKG_LIST=()
    else
      PKG_LIST=($(echo "$PACKAGES" | awk '{print $1}'))
      echo "📦 Paket yang tersedia untuk update (${#PKG_LIST[@]}):"
      echo

      # Buat tabel berwarna + ikon
      PKG_TABLE=$(printf "%-45s %-20s %-10s\n" "Paket" "Versi Baru" "Kategori"
                  printf "%-45s %-20s %-10s\n" "------" "----------" "--------"
                  while IFS= read -r line; do
                    pkg=$(echo "$line" | awk '{print $1}')
                    ver=$(echo "$line" | awk '{print $2}')
                    catpkg=$(get_package_category "$pkg")
                    pkg_colored=$(color_for_category "$catpkg" "$pkg")
                    printf "%-45b %-20s %-10s\n" "$pkg_colored" "$ver" "$catpkg"
                  done <<< "$PACKAGES")

      # Tampilkan tabel lewat pager biar rapi
      echo "$PKG_TABLE" | gum pager

      # Hitung kategori
      declare -A category_counts=( ["System"]=0 ["Driver"]=0 ["Package"]=0 )
      for pkg in "${PKG_LIST[@]}"; do
        catpkg=$(get_package_category "$pkg")
        ((category_counts[$catpkg]++))
      done
      echo
      echo "⚠️ Kategori paket yang akan diupdate:"
      echo -e "  - ${YELLOW}${ICON_SYSTEM} System${RESET}  : ${category_counts[System]}"
      echo -e "  - ${RED}${ICON_DRIVER} Driver${RESET}  : ${category_counts[Driver]}"
      echo -e "  - ${GREEN}${ICON_PACKAGE} Package${RESET} : ${category_counts[Package]}"
      echo
    fi

    # Pastikan ada jeda sebelum menu
    echo

    CHOICE=$(gum choose --cursor.foreground 212 --limit 1 \
      "Update semua paket" \
      "Pilih paket untuk diupdate" \
      "Lihat daftar paket terinstall" \
      "Lihat paket terinstall berdasarkan ukuran" \
      "Batal")

    case "$CHOICE" in
      "Update semua paket")
        update_all_with_retry
        ;;
      "Pilih paket untuk diupdate")
        if (( ${#PKG_LIST[@]} == 0 )); then
          echo "Tidak ada paket untuk diupdate."
        else
          SELECTED=($(printf '%s\n' "${PKG_LIST[@]}" | gum choose --no-limit --cursor.foreground 212 --height 10 --header "Pilih paket yang ingin diupdate (space untuk pilih)"))
          if (( ${#SELECTED[@]} > 0 )); then
            update_selected_with_retry "${SELECTED[@]}"
          else
            echo "❌ Tidak ada paket dipilih."
          fi
        fi
        ;;
      "Lihat daftar paket terinstall")
        show_installed_packages
        ;;
      "Lihat paket terinstall berdasarkan ukuran")
        show_installed_by_size
        ;;
      "Batal")
        echo "❌ Dibatal."
        break
        ;;
    esac
  done
}

main "$@"
