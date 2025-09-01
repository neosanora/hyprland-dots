#!/usr/bin/env bash
# --------------------------------------------------------------
# Install Bibata cursor themes + extract manual cursor archives
# - safer, idempotent, wget/curl fallback, basic error handling
# - expects optional custom archives in ./cursors relative to script
# --------------------------------------------------------------
set -euo pipefail
IFS=$'\n\t'

# --- Config ---
DOWNLOAD_FOLDER="${DOWNLOAD_FOLDER:-$HOME/Downloads/bibata-cursors}"
BIBATA_BASE_URL="https://github.com/ful1e5/Bibata_Cursor/releases/download/v2.0.7"
ICONS_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/icons"
THEMES=("Amber" "Classic" "Ice")
CUSTOM_ARCHIVES=(
  "ComixCursors-0.10.1.tar.bz2"
  "oreo-spark-dark-cursors.tar.gz"
  "oreo-spark-purple-cursors.tar.gz"
)

# --- Helpers ---
err() { echo "[ERROR] $*" >&2; }
info() { echo "[INFO] $*"; }
check_cmd() { command -v "$1" >/dev/null 2>&1 || return 1; }

download() {
  local url="$1" out="$2"
  if check_cmd wget; then
    wget -q --show-progress -O "$out" "$url"
  elif check_cmd curl; then
    curl -L --fail -# -o "$out" "$url"
  else
    return 2
  fi
}

# --- Preconditions ---
if ! check_cmd tar; then
  err "'tar' is required. Install it and run again."
  exit 1
fi
if ! check_cmd wget && ! check_cmd curl; then
  err "Either 'wget' or 'curl' is required. Install one and run again."
  exit 1
fi

# --- Prepare directories ---
info "Creating folders: $DOWNLOAD_FOLDER and $ICONS_DIR"
mkdir -p "$DOWNLOAD_FOLDER" "$ICONS_DIR"

# --- Remove old Bibata installations (safe) ---
for theme in "${THEMES[@]}"; do
  old_dir="$ICONS_DIR/Bibata-Modern-$theme"
  if [ -d "$old_dir" ]; then
    info "Removing old theme: $old_dir"
    rm -rf -- "$old_dir"
  fi
done

# --- Download & extract official Bibata themes ---
for theme in "${THEMES[@]}"; do
  filename="Bibata-Modern-$theme.tar.xz"
  url="$BIBATA_BASE_URL/$filename"
  out="$DOWNLOAD_FOLDER/$filename"

  info "Downloading $filename"
  if download "$url" "$out"; then
    info "Extracting $filename -> $ICONS_DIR"
    if ! tar -xf "$out" -C "$ICONS_DIR"; then
      err "Failed to extract $out"
    fi
  else
    err "Failed to download $url (skipping)."
  fi
done

# --- Extract custom cursor archives (if present) ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
for archive in "${CUSTOM_ARCHIVES[@]}"; do
  src="$SCRIPT_DIR/cursors/$archive"
  if [ -f "$src" ]; then
    info "Extracting custom archive: $archive"
    if ! tar -xf "$src" -C "$ICONS_DIR"; then
      err "Failed to extract $src"
    fi
  else
    info "Custom archive not found, skipping: $archive"
  fi
done

# --- Final touches ---
# Ensure reasonable permissions
info "Setting permissions on $ICONS_DIR"
find "$ICONS_DIR" -type d -exec chmod 755 {} + 2>/dev/null || true

info "✅ Cursor themes installed into: $ICONS_DIR"

cat <<'EOF'
Next steps (pick one depending on your desktop environment):
- GNOME: gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Classic'
- KDE / other: set theme in System Settings or log out / log in to reload cursor cache
- General: if a session doesn't pick it up immediately, log out/in or reboot.

If you want the script to remove the temporary downloads folder after successful run, set DOWNLOAD_FOLDER to a temp path or manually delete it.
EOF
