#!/usr/bin/env bash
set -euo pipefail

########################################
# 1. KONFIGURASI WARNA DAN IKON
########################################
YELLOW="\033[33m"
RED="\033[31m"
GREEN="\033[32m"
RESET="\033[0m"

ICON_SYSTEM="🖥"
ICON_DRIVER="🎮"
ICON_PACKAGE="📦"

########################################
# 2. FUNGSI ERROR DAN PENGECEKAN
########################################
error_exit() {
  echo "❌ $1" >&2
  exit 1
}

check_command() {
  if ! command -v "$1" &>/dev/null; then
    error_exit "$1 belum terinstall. Jalankan: sudo pacman -S $1"
  fi
}

########################################
# 3. FUNGSI KATEGORI DAN WARNA
########################################
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

########################################
# 4. FUNGSI FORMAT TABEL (ANSI SAFE)
########################################
strip_ansi() {
  sed 's/\x1B\[[0-9;]*[A-Za-z]//g'
}

ansi_safe_table() {
  local -a col1 col2 col3
  local max1=0 max2=0 max3=0

  while IFS=$'\t' read -r c1 c2 c3; do
    col1+=("$c1")
    col2+=("$c2")
    col3+=("$c3")

    local l1 l2 l3
    l1=$(echo -ne "$c1" | strip_ansi | wc -m)
    l2=$(echo -ne "$c2" | strip_ansi | wc -m)
    l3=$(echo -ne "$c3" | strip_ansi | wc -m)

    (( l1 > max1 )) && max1=$l1
    (( l2 > max2 )) && max2=$l2
    (( l3 > max3 )) && max3=$l3
  done

  for ((i=0; i<${#col1[@]}; i++)); do
    printf "%-${max1}s  %-${max2}s  %-${max3}s\n" \
      "$(echo -ne "${col1[i]}")" \
      "$(echo -ne "${col2[i]}")" \
      "$(echo -ne "${col3[i]}")"
  done
}

########################################
# 5. FUNGSI UPDATE SISTEM
########################################
update_all_with_retry() {
  sudo -v
  echo "🔄 Mulai update semua paket..."
  until sudo pacman -Syu; do
    echo "⚠️ Update gagal, ulang dalam 5 detik..."
    sleep 5
  done
  echo "✅ Update selesai."
}

update_selected_with_retry() {
  local -a selected_pkgs=("$@")
  sudo -v
  echo "🔄 Mengupdate paket terpilih..."
  until sudo pacman -S --needed "${selected_pkgs[@]}"; do
    echo "⚠️ Update gagal, ulang dalam 5 detik..."
    sleep 5
  done
  echo "✅ Update paket terpilih selesai."
}

########################################
# 6. FUNGSI TAMPILAN DAFTAR PAKET
########################################
show_installed_packages() {
  echo "📋 Daftar paket terinstall:"
  {
    echo -e "Paket\tVersi\tKategori"
    echo -e "------\t-----\t--------"
    pacman -Q | while read -r pkg ver; do
      catpkg=$(get_package_category "$pkg")
      pkg_colored=$(color_for_category "$catpkg" "$pkg")
      echo -e "$pkg_colored\t$ver\t$catpkg"
    done
  } | ansi_safe_table | (command -v gum &>/dev/null && gum pager || less -R)
  echo
}

show_installed_by_size() {
  echo "📏 Daftar paket berdasarkan ukuran:"
  {
    echo -e "Paket\tUkuran\tKategori"
    echo -e "------\t------\t--------"
    pacman -Qi | awk '
      /^Name/ {name=$3}
      /^Installed Size/ {
        size=$4
        unit=$5
        if (unit=="MiB") {size_kb=size*1024}
        else if (unit=="GiB") {size_kb=size*1024*1024}
        else if (unit=="KiB") {size_kb=size}
        else {size_kb=0}
        print name "\t" size " " unit
      }
    ' | sort -k2 -nr | while read -r pkg size unit; do
      catpkg=$(get_package_category "$pkg")
      pkg_colored=$(color_for_category "$catpkg" "$pkg")
      echo -e "$pkg_colored\t$size\t$catpkg"
    done
  } | ansi_safe_table | (command -v gum &>/dev/null && gum pager || less -R)
  echo
}

########################################
# 7. FUNGSI SETUP EXIT
########################################
setup_exit_trap() {
  if [ -t 1 ]; then
    trap 'read -r -p "Tekan ENTER untuk menutup..."' EXIT
  fi
}

########################################
# 8. FUNGSI UTAMA
########################################
main() {
  setup_exit_trap
  check_command checkupdates
  check_command pacman

  if ! command -v gum &>/dev/null; then
    echo "⚠️ gum tidak ditemukan, beberapa fitur akan fallback."
  fi

  while true; do
    PACKAGES=$(checkupdates 2>/dev/null || true)
    PKG_LIST=()

    if [[ -n "$PACKAGES" ]]; then
      mapfile -t PKG_LIST < <(echo "$PACKAGES" | awk '{print $1}')
    fi

    echo
    if command -v gum &>/dev/null; then
      CHOICE=$(gum choose --cursor.foreground 212 --limit 1 \
        "Lihat daftar paket update" \
        "Update semua paket" \
        "Pilih paket untuk diupdate" \
        "Lihat daftar paket terinstall" \
        "Lihat paket terinstall berdasarkan ukuran" \
        "Batal")
    else
      echo "1) Lihat daftar paket update"
      echo "2) Update semua paket"
      echo "3) Pilih paket untuk diupdate"
      echo "4) Lihat daftar paket terinstall"
      echo "5) Lihat paket terinstall berdasarkan ukuran"
      echo "6) Batal"
      read -rp "Pilih opsi [1-6]: " CHOICE
    fi

    case "$CHOICE" in
      "Lihat daftar paket update"|"1")
        if (( ${#PKG_LIST[@]} == 0 )); then
          echo "✅ Tidak ada paket untuk diupdate."
        else
          echo "📦 Paket yang tersedia untuk update (${#PKG_LIST[@]}):"
          {
            echo -e "Paket\tVersi Baru\tKategori"
            echo -e "------\t----------\t--------"
            while IFS= read -r line; do
              pkg=$(echo "$line" | awk '{print $1}')
              ver=$(echo "$line" | awk '{print $2}')
              catpkg=$(get_package_category "$pkg")
              pkg_colored=$(color_for_category "$catpkg" "$pkg")
              echo -e "$pkg_colored\t$ver\t$catpkg"
            done <<< "$PACKAGES"
          } | ansi_safe_table | (command -v gum &>/dev/null && gum pager || less -R)
        fi
        ;;
      "Update semua paket"|"2")
        update_all_with_retry
        ;;
      "Pilih paket untuk diupdate"|"3")
        if (( ${#PKG_LIST[@]} == 0 )); then
          echo "❌ Tidak ada paket untuk diupdate."
        else
          if command -v gum &>/dev/null; then
            mapfile -t SELECTED < <(printf '%s\n' "${PKG_LIST[@]}" \
              | gum choose --no-limit --cursor.foreground 212 --height 10 \
                --header "Pilih paket yang ingin diupdate (space untuk pilih)")
          else
            echo "Daftar paket:"
            select pkg in "${PKG_LIST[@]}"; do
              SELECTED=("$pkg")
              break
            done
          fi
          if (( ${#SELECTED[@]} > 0 )); then
            update_selected_with_retry "${SELECTED[@]}"
          else
            echo "❌ Tidak ada paket dipilih."
          fi
        fi
        ;;
      "Lihat daftar paket terinstall"|"4")
        show_installed_packages
        ;;
      "Lihat paket terinstall berdasarkan ukuran"|"5")
        show_installed_by_size
        ;;
      "Batal"|"6"|"Batal"|*)
        echo "❌ Dibatal."
        break
        ;;
    esac
  done
}

main "$@"
