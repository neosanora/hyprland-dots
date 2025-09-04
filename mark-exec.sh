#!/usr/bin/env bash

# Root folders
ROOTS=("dotfiles" "setup")

# Exclude map (folder yang mau di-skip per root)
declare -A EXCLUDES
EXCLUDES["dotfiles"]=".config/ml4w/settings .config/ml4w/version .config/waybar/themes"
EXCLUDES["setup"]="scripts/old install/backup"

# List semua file target
FILES_TO_UPDATE=()

for ROOT in "${ROOTS[@]}"; do
  echo ":: Scanning $ROOT"

  # Bangun argumen exclude sesuai root
  EXCLUDE_ARGS=()
  for dir in ${EXCLUDES[$ROOT]}; do
    EXCLUDE_ARGS+=( ! -path "$ROOT/$dir/*" )
  done

  # 1. .sh di dalam .config
  if [[ -d "$ROOT/.config" ]]; then
    FILES=$(find "$ROOT/.config" -type f -name "*.sh" "${EXCLUDE_ARGS[@]}")
    FILES_TO_UPDATE+=($FILES)
  fi

  # 2. .sh di root level
  FILES=$(find "$ROOT" -maxdepth 1 -type f -name "*.sh")
  FILES_TO_UPDATE+=($FILES)
done

# Tampilkan daftar file
echo
echo ":: File yang akan di-mark executable:"
for f in "${FILES_TO_UPDATE[@]}"; do
  echo "   $f"
done

# Tanya user
echo
read -p "Lanjutkan update-index untuk semua file di atas? (y/n): " CONFIRM
if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
  for f in "${FILES_TO_UPDATE[@]}"; do
    git update-index --chmod=+x "$f"
  done
  echo ":: Done. Semua file sudah di-mark executable."
else
  echo ":: Dibatalkan. Tidak ada perubahan."
fi
