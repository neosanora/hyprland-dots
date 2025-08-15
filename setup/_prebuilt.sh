#!/usr/bin/env bash
# --------------------------------------------------------------
# Auto Download & Install Prebuilt Binaries (Matugen & Wallust)
# Default to latest version if no input provided
# Skip installation if already exists
# --------------------------------------------------------------

set -e
BIN_DIR="$HOME/.local/bin"
echo "[DEBUG] BIN_DIR set to: $BIN_DIR"
mkdir -p "$BIN_DIR"

# Function to fetch latest release tag from GitHub/Codeberg API
get_latest_release() {
    local repo_url="$1"
    echo "[DEBUG] Fetching latest release from: $repo_url"
    curl -s "$repo_url" | grep -oP 'tag_name":"\K[^" ]+' | head -n 1
}

# Prompt with default value = latest
read -rp "Enter Matugen version (default: latest): " MATUGEN_VER
MATUGEN_VER=${MATUGEN_VER:-latest}
echo "[DEBUG] User chose Matugen version: $MATUGEN_VER"
if [[ "$MATUGEN_VER" == "latest" ]]; then
    MATUGEN_VER=$(get_latest_release "https://api.github.com/repos/InioX/matugen/releases")
    echo "[DEBUG] Latest Matugen version resolved to: $MATUGEN_VER"
fi

read -rp "Enter Wallust version (default: latest): " WALLUST_VER
WALLUST_VER=${WALLUST_VER:-latest}
echo "[DEBUG] User chose Wallust version: $WALLUST_VER"
if [[ "$WALLUST_VER" == "latest" ]]; then
    WALLUST_VER=$(get_latest_release "https://codeberg.org/api/v1/repos/explosion-mental/wallust/releases")
    echo "[DEBUG] Latest Wallust version resolved to: $WALLUST_VER"
fi

# URLs for prebuilt binaries only
MATUGEN_URL="https://github.com/InioX/matugen/releases/download/${MATUGEN_VER}/matugen"
WALLUST_URL="https://codeberg.org/explosion-mental/wallust/releases/download/${WALLUST_VER}/wallust"
echo "[DEBUG] Matugen prebuilt binary URL: $MATUGEN_URL"
echo "[DEBUG] Wallust prebuilt binary URL: $WALLUST_URL"

# Install Matugen if not exists
if [[ -f "$BIN_DIR/matugen" ]]; then
    echo "Matugen already exists at $BIN_DIR/matugen, skipping installation."
else
    echo "Installing Matugen ${MATUGEN_VER} into ${BIN_DIR}"
    wget -q --show-progress -O "$BIN_DIR/matugen" "$MATUGEN_URL"
    chmod +x "$BIN_DIR/matugen"
    echo "[DEBUG] Matugen installed at: $BIN_DIR/matugen"
fi

# Install Wallust if not exists
if [[ -f "$BIN_DIR/wallust" ]]; then
    echo "Wallust already exists at $BIN_DIR/wallust, skipping installation."
else
    echo "Installing Wallust ${WALLUST_VER} into ${BIN_DIR}"
    wget -q --show-progress -O "$BIN_DIR/wallust" "$WALLUST_URL"
    chmod +x "$BIN_DIR/wallust"
    echo "[DEBUG] Wallust installed at: $BIN_DIR/wallust"
fi

echo "✅ Installation complete."
