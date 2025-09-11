#!/usr/bin/env bash
# ------------------------------------------------------------
# Install / Update Matugen (pakai wget + jq dengan fallback lokal)
# ------------------------------------------------------------
set -euo pipefail

REPO="InioX/matugen"
INSTALL_DIR="$HOME/.local/bin"
TMP_DIR="$(mktemp -d)"
BINARY_NAME="matugen"
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

mkdir -p "$INSTALL_DIR"

# -----------------------------
# Cek dependensi
# -----------------------------
for cmd in wget tar jq mktemp; do
    command -v "$cmd" >/dev/null 2>&1 || {
        echo "[ERROR] $cmd tidak ditemukan di PATH!"
        exit 1
    }
done

# -----------------------------
# Ambil release terbaru
# -----------------------------
echo "[INFO] Mengambil daftar release Matugen..."
if ! RELEASE_JSON=$(wget -qO- "https://api.github.com/repos/$REPO/releases"); then
    echo "[WARN] Gagal mengambil daftar release dari GitHub, pakai fallback lokal..."
    install -m 755 "$SCRIPT_DIR/packages/$BINARY_NAME" "$INSTALL_DIR/$BINARY_NAME"
    echo "[SUCCESS] Matugen fallback berhasil dipasang di $INSTALL_DIR"
    exit 0
fi

LATEST_RELEASE=$(echo "$RELEASE_JSON" | jq -r '.[0].tag_name')
echo "[INFO] Versi terbaru: $LATEST_RELEASE"

ASSET_URL=$(echo "$RELEASE_JSON" \
    | jq -r '.[0].assets[] 
        | select(.browser_download_url | test("x86_64\\.tar\\.gz$")) 
        | .browser_download_url')

if [[ -z "$ASSET_URL" || "$ASSET_URL" == "null" ]]; then
    echo "[WARN] Tidak menemukan asset Linux untuk release $LATEST_RELEASE, pakai fallback lokal..."
    install -m 755 "$SCRIPT_DIR/packages/$BINARY_NAME" "$INSTALL_DIR/$BINARY_NAME"
    echo "[SUCCESS] Matugen fallback berhasil dipasang di $INSTALL_DIR"
    exit 0
fi

# -----------------------------
# Download pakai wget
# -----------------------------
echo "[INFO] Downloading $ASSET_URL ..."
cd "$TMP_DIR"
if ! wget -q --show-progress "$ASSET_URL"; then
    echo "[WARN] Download gagal, pakai fallback lokal..."
    install -m 755 "$SCRIPT_DIR/packages/$BINARY_NAME" "$INSTALL_DIR/$BINARY_NAME"
    echo "[SUCCESS] Matugen fallback berhasil dipasang di $INSTALL_DIR"
    exit 0
fi

FILENAME=$(basename "$ASSET_URL")

# -----------------------------
# Extract dan install
# -----------------------------
if ! tar -xzf "$FILENAME"; then
    echo "[WARN] Extract gagal, pakai fallback lokal..."
    install -m 755 "$SCRIPT_DIR/packages/$BINARY_NAME" "$INSTALL_DIR/$BINARY_NAME"
    echo "[SUCCESS] Matugen fallback berhasil dipasang di $INSTALL_DIR"
    rm -rf "$TMP_DIR"
    exit 0
fi

BIN_PATH=$(find . -type f -name "$BINARY_NAME" | head -n1)
if [[ -n "$BIN_PATH" ]]; then
    install -m 755 "$BIN_PATH" "$INSTALL_DIR/$BINARY_NAME"
else
    echo "[WARN] Binary $BINARY_NAME tidak ditemukan dalam archive, pakai fallback lokal..."
    install -m 755 "$SCRIPT_DIR/packages/$BINARY_NAME" "$INSTALL_DIR/$BINARY_NAME"
    echo "[SUCCESS] Matugen fallback berhasil dipasang di $INSTALL_DIR"
    rm -rf "$TMP_DIR"
    exit 0
fi

# -----------------------------
# Bersihkan tmp
# -----------------------------
rm -rf "$TMP_DIR"

echo "[SUCCESS] Matugen $LATEST_RELEASE berhasil diinstal di $INSTALL_DIR"
echo "[INFO] Versi terpasang:"
"$INSTALL_DIR/$BINARY_NAME" --version || true