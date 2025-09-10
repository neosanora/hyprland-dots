#!/usr/bin/env bash
set -euo pipefail


#================================================================#
# CHANGE 
#================================================================#

# Root folders yang akan discan
ROOTS=(
       "dotfiles"
       "setup"
      )

# Exclude map (per-root)
declare -A EXCLUDES
EXCLUDES["dotfiles"]="
                      .config/ml4w/settings
                      .config/ml4w/version
                      .config/waybar/themes
                     "

EXCLUDES["setup"]="
                  scripts/old
                  install/backup
                  "

# Pola file/folder (generik)
PATTERNS=(
          "*.sh"
         )

# Target spesifik (manual, bisa file/folder)
EXTRA_TARGETS=(
  "dotfiles/.config/sidepad"
  "dotfiles/.config/waybar/neobar/scripts/custom/ddc-brightness"
)

#================================================================#
# MAIN PARTS (Don't change this)
#================================================================#

# Don't change this
FILES_TO_UPDATE=()

# Build exclude args per-root
function build_excludes() {
  local root="$1"
  local args=()
  for dir in ${EXCLUDES[$root]:-}; do
    args+=( ! -path "$root/$dir" ! -path "$root/$dir/*" )
  done
  echo "${args[@]}"
}

# Cari berdasarkan patterns
for ROOT in "${ROOTS[@]}"; do
  echo ":: Scanning $ROOT"

  EXCLUDE_ARGS=($(build_excludes "$ROOT"))

  for pat in "${PATTERNS[@]}"; do
    if [[ "$pat" == */* ]]; then
      # Kalau pattern mengarah ke folder (contoh: bin/*)
      if [[ -d "$ROOT/$pat" ]]; then
        while IFS= read -r f; do
          FILES_TO_UPDATE+=("$f")
        done < <(find "$ROOT/$pat" -type f "${EXCLUDE_ARGS[@]}")
      fi
    else
      # Kalau pattern file biasa (*.sh, *.py)
      if [[ -d "$ROOT/.config" ]]; then
        while IFS= read -r f; do
          FILES_TO_UPDATE+=("$f")
        done < <(find "$ROOT/.config" -type f -name "$pat" "${EXCLUDE_ARGS[@]}")
      fi
      while IFS= read -r f; do
        FILES_TO_UPDATE+=("$f")
      done < <(find "$ROOT" -maxdepth 1 -type f -name "$pat" "${EXCLUDE_ARGS[@]}")
    fi
  done
done

# Tambahkan EXTRA_TARGETS (dengan exclude check juga)
for f in "${EXTRA_TARGETS[@]}"; do
  if [[ -d "$f" ]]; then
    while IFS= read -r x; do
      FILES_TO_UPDATE+=("$x")
    done < <(find "$f" -type f $(build_excludes "$(dirname "$f")"))
  elif [[ -f "$f" ]]; then
    skip=0
    for ex in ${EXCLUDES["$(dirname "$f")"]:-}; do
      [[ "$f" == *"$ex" ]] && skip=1
    done
    [[ $skip -eq 0 ]] && FILES_TO_UPDATE+=("$f")
  fi
done

# Hapus duplikat
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
    chmod +x "$f"
    git update-index --chmod=+x "$f" || true
  done
  echo ":: Done."
else
  echo ":: Dibatalkan."
fi
