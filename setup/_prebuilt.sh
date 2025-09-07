#!/usr/bin/env bash
# ------------------------------------------------------------
# Script Install / Update Matugen (Versi terbaru otomatis)
# ------------------------------------------------------------
set -euo pipefail

REPO="InioX/matugen"
INSTALL_DIR="$HOME/.local/bin"
TMP_DIR="$(mktemp -d)"
BINARY_NAME="matugen"

mkdir -p "$INSTALL_DIR"

# -----------------------------
# Fungsi bantu
# -----------------------------
function command_exists() {
    command -v "$1" >/dev/null 2>&1
}

function get_latest_release() {
    curl -s "https://api.github.com/repos/$REPO/releases/latest" \
        | grep '"tag_name":' \
        | sed -E 's/.*"([^"]+)".*/\1/'
}

function get_asset_url() {
    curl -s "https://api.github.com/repos/$REPO/releases/latest" \
        | grep browser_download_url \
        | grep linux \
        | cut -d '"' -f 4
}

function get_local_version() {
    if [[ -x "$INSTALL_DIR/$BINARY_NAME" ]]; then
        "$INSTALL_DIR/$BINARY_NAME" --version 2>/dev/null || echo "0.0.0"
    else
        echo "0.0.0"
    fi
}

# -----------------------------
# Ambil versi terbaru & local
# -----------------------------
LATEST_RELEASE=$(get_latest_release)
LOCAL_VERSION=$(get_local_version)

echo "[INFO] Versi terbaru: $LATEST_RELEASE"
echo "[INFO] Versi terinstall: $LOCAL_VERSION"

# -----------------------------
# Cek apakah perlu update
# -----------------------------
if [[ "$LOCAL_VERSION" == "$LATEST_RELEASE" ]]; then
    echo "[INFO] Matugen sudah versi terbaru. Tidak perlu update."
    exit 0
fi

# -----------------------------
# Download release terbaru
# -----------------------------
ASSET_URL=$(get_asset_url)

if [[ -z "$ASSET_URL" ]]; then
    echo "[ERROR] Gagal menemukan asset untuk Linux!"
    exit 1
fi

echo "[INFO] Downloading $ASSET_URL ..."
cd "$TMP_DIR"
curl -LO "$ASSET_URL"

FILENAME=$(basename "$ASSET_URL")

# -----------------------------
# Extract / Install
# -----------------------------
if [[ "$FILENAME" == *.tar.gz ]]; then
    tar -xzf "$FILENAME" -C "$INSTALL_DIR"
elif [[ "$FILENAME" == *.zip ]]; then
    unzip -o "$FILENAME" -d "$INSTALL_DIR"
else
    chmod +x "$FILENAME"
    mv -f "$FILENAME" "$INSTALL_DIR/$BINARY_NAME"
fi

# -----------------------------
# Bersihkan tmp
# -----------------------------
rm -rf "$TMP_DIR"

# -----------------------------
# DONE
# -----------------------------

echo "[SUCCESS] Matugen $LATEST_RELEASE berhasil diinstal/diupdate di $INSTALL_DIR"
