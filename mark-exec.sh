#!/usr/bin/env bash

# Root folders
ROOTS=("dotfiles" "setup")

# Exclude map
declare -A EXCLUDES
EXCLUDES["dotfiles"]=".config/ml4w/settings .config/ml4w/version .config/waybar/themes"
EXCLUDES["setup"]="scripts/old install/backup"

# File/folder manual
EXTRA_TARGETS=(
  "dotfiles/.config/sidepad"
)

# Pola file yang mau dicari
PATTERNS=("*.sh")

FILES_TO_UPDATE=()

for ROOT in "${ROOTS[@]}"; do
  echo ":: Scanning $ROOT"

  EXCLUDE_ARGS=()
  for dir in ${EXCLUDES[$ROOT]}; do
    EXCLUDE_ARGS+=( ! -path "$ROOT/$dir/*" )
  done

  # Cari sesuai pola
  for pat in "${PATTERNS[@]}"; do
    if [[ -d "$ROOT/.config" ]]; then
      while IFS= read -r f; do
        FILES_TO_UPDATE+=("$f")
      done < <(find "$ROOT/.config" -type f -name "$pat" "${EXCLUDE_ARGS[@]}")
    fi

    while IFS= read -r f; do
      FILES_TO_UPDATE+=("$f")
    done < <(find "$ROOT" -maxdepth 1 -type f -name "$pat")
  done
done

# Tambahkan manual
FILES_TO_UPDATE+=("${EXTRA_TARGETS[@]}")

# Hapus duplikat (jaga2 kalau overlap pattern)
FILES_TO_UPDATE=($(printf "%s\n" "${FILES_TO_UPDATE[@]}" | sort -u))

echo
echo ":: File/folder yang akan di-mark executable:"
for f in "${FILES_TO_UPDATE[@]}"; do
  echo "   $f"
done
echo ":: Total: ${#FILES_TO_UPDATE[@]}"

echo
read -p "Lanjutkan chmod +x & update-index untuk semua di atas? (y/n): " CONFIRM
if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
  for f in "${FILES_TO_UPDATE[@]}"; do
    if [[ -d "$f" ]]; then
      chmod -R +x "$f"
      git add "$f"
    else
      chmod +x "$f"
      git update-index --chmod=+x "$f"
    fi
  done
  echo ":: Done."
else
  echo ":: Dibatalkan."
fi
