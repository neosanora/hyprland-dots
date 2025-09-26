#!/usr/bin/env bash

# ========================================= #
FONT_URL="https://github.com/<username>/San-Francisco-family.git"
FONTS=("SF Pro" "SF Serif" "SF Mono")

# ========================================= #

FONT_DIR="/tmp/San-Francisco-family"
SYSTEM_FONT_LOCATION="/usr/local/share/fonts/otf"

# ========================================= #

clone_repo() {
    echo
    echo "### Cloning repo... ###"
    echo

    git clone -n --depth=1 --filter=tree:0 "$FONT_URL" "$FONT_DIR"
    cd "$FONT_DIR" || exit
    git sparse-checkout set --no-cone "${FONTS[@]}"
    git checkout
}

copy_files() {
    echo
    echo "### Copying files... ###"
    echo

    for font in "${FONTS[@]}"; do
        # buat folder tujuan lowercase tanpa spasi
        folder_name=$(echo "$font" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
        sudo mkdir -p "$SYSTEM_FONT_LOCATION/$folder_name"

        # copy semua .otf dari folder font
        sudo cp "$FONT_DIR/$font"/*.otf "$SYSTEM_FONT_LOCATION/$folder_name" 2>/dev/null || true
    done

    echo
    echo "### Cleaning up... ###"
    rm -rf "$FONT_DIR"

    echo
    echo "### Done! ###"
    echo
}

if ! command -v git >/dev/null; then
    echo "Install git first"
    exit 1
fi

clone_repo
copy_files