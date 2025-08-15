#!/usr/bin/env bash
# --------------------------------------------------------------
# Auto Download & Install Fonts (FiraCode & Fira Sans)
# Niconne & Satisfy are copied from local fonts directory only
# Skip installation if already exists
# --------------------------------------------------------------

set -e

SYSTEM_FONTS_DIR="/usr/share/fonts"
echo "[DEBUG] SYSTEM_FONTS_DIR set to: $SYSTEM_FONTS_DIR"
mkdir -p "$SYSTEM_FONTS_DIR"

# Function to copy font if not already installed
install_font_local() {
    local font_name="$1"
    local source_dir="$2"
    local target_dir="$SYSTEM_FONTS_DIR/$font_name"

    if [[ -d "$target_dir" ]]; then
        echo "[DEBUG] Font $font_name already exists, skipping installation."
    else
        echo "Installing local font: $font_name"
        sudo cp -rf "$source_dir/$font_name" "$SYSTEM_FONTS_DIR"
        echo "[DEBUG] Font $font_name installed to $SYSTEM_FONTS_DIR"
    fi
}

# Function to download and install font if not already installed
download_and_install_font() {
    local font_name="$1"
    local font_url="$2"
    local target_dir="$SYSTEM_FONTS_DIR/$font_name"

    if [[ -d "$target_dir" ]]; then
        echo "[DEBUG] Font $font_name already exists, skipping download."
    else
        echo "Downloading and installing font: $font_name"
        tmp_zip="/tmp/${font_name}.zip"
        wget -q --show-progress -O "$tmp_zip" "$font_url"
        sudo mkdir -p "$target_dir"
        sudo unzip -oq "$tmp_zip" -d "$target_dir"
        rm "$tmp_zip"
        echo "[DEBUG] Font $font_name installed to $SYSTEM_FONTS_DIR"
    fi
}

# SCRIPT_DIR detection
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "[DEBUG] SCRIPT_DIR set to: $SCRIPT_DIR"

# Install FiraCode & Fira Sans from web if not exists
download_and_install_font "FiraCode" "https://github.com/tonsky/FiraCode/releases/latest/download/Fira_Code_v6.2.zip"
download_and_install_font "Fira_Sans" "https://github.com/mozilla/Fira/releases/latest/download/Fira_Sans.zip"

# Install Niconne & Satisfy from local (no download)
install_font_local "Niconne" "$SCRIPT_DIR/fonts"
install_font_local "Satisfy" "$SCRIPT_DIR/fonts"

echo "✅ Font installation complete."

