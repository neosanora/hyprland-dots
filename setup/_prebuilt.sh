#!/usr/bin/env bash
# ------------------------------------------------------------
# Install / Update Matugen (pakai wget)
# ------------------------------------------------------------
set -euo pipefail

REPO="InioX/matugen"
INSTALL_DIR="$HOME/.local/bin"
TMP_DIR="$(mktemp -d)"
BINARY_NAME="matugen"

mkdir -p "$INSTALL_DIR"

# -----------------------------
# Ambil release terbaru
# -----------------------------
echo "[INFO] Mengambil daftar release Matugen..."
RELEASE_JSON=$(wget -qO- "https://api.github.com/repos/$REPO/releases")

LATEST_RELEASE=$(echo "$RELEASE_JSON" | grep -m1 '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
echo "[INFO] Versi terbaru: $LATEST_RELEASE"

# -----------------------------
# Ambil URL asset Linux (.tar.gz)
# -----------------------------
ASSET_URL=$(echo "$RELEASE_JSON" \
    | grep -A 5 "$LATEST_RELEASE" \
    | grep '"browser_download_url":' \
    | grep 'x86_64.tar.gz' \
    | cut -d '"' -f 4)

if [[ -z "$ASSET_URL" ]]; then
    echo "[ERROR] Gagal menemukan asset Linux untuk release $LATEST_RELEASE!"
    exit 1
fi

# -----------------------------
# Download pakai wget
# -----------------------------
echo "[INFO] Downloading $ASSET_URL ..."
cd "$TMP_DIR"
wget -q --show-progress "$ASSET_URL"

FILENAME=$(basename "$ASSET_URL")

# -----------------------------
# Extract dan install
# -----------------------------
tar -xzf "$FILENAME" -C "$INSTALL_DIR"

# -----------------------------
# Bersihkan tmp
# -----------------------------
rm -rf "$TMP_DIR"

echo "[SUCCESS] Matugen $LATEST_RELEASE berhasil diinstal di $INSTALL_DIR"
echo "Pastikan $INSTALL_DIR ada di PATH Anda."
