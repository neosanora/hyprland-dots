#!/usr/bin/env bash
# --------------------------------------------------------------
# Auto Download & Install Prebuilt Binaries (Customizable)
# Supports multiple packages via single array definition
# Default to latest version if no input provided
# Skip installation if already exists
# Skip download if URL is invalid or unreachable
# --------------------------------------------------------------

set -e
BIN_DIR="$HOME/.local/bin"
mkdir -p "$BIN_DIR"

# --------------------------------------------------------------
# Package List (format: "name|repo_api|base_url")
# - name      : nama binary
# - repo_api  : API URL untuk fetch release (kosongkan kalau versi fixed)
# - base_url  : URL dasar untuk prebuilt binary
# --------------------------------------------------------------
PACKAGES=(
  "matugen|https://api.github.com/repos/InioX/matugen/releases|https://github.com/InioX/matugen/releases/download"
  "wallust|https://codeberg.org/api/v1/repos/explosion-mental/wallust/releases|https://codeberg.org/explosion-mental/wallust/releases/download"
)

# --------------------------------------------------------------
# Function untuk fetch versi release terbaru
# --------------------------------------------------------------
get_latest_release() {
    local repo_url="$1"
    curl -fsSL "$repo_url" | grep -oP 'tag_name":"\K[^" ]+' | head -n 1 || true
}

# --------------------------------------------------------------
# Function untuk cek apakah URL valid
# --------------------------------------------------------------
check_url() {
    local url="$1"
    if curl -fsI "$url" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# --------------------------------------------------------------
# Main installer loop
# --------------------------------------------------------------
for pkg in "${PACKAGES[@]}"; do
    IFS="|" read -r NAME API_URL BASE_URL <<< "$pkg"

    # Prompt versi
    read -rp "Enter ${NAME^} version (default: latest): " VER
    VER=${VER:-latest}
    if [[ "$VER" == "latest" ]]; then
        if [[ -n "$API_URL" ]]; then
            VER=$(get_latest_release "$API_URL")
            [[ -z "$VER" ]] && echo "⚠️ Failed to fetch latest version for $NAME, skipping." && continue
            echo "[DEBUG] Latest $NAME version resolved to: $VER"
        else
            echo "⚠️ No API defined for $NAME and version=latest, skipping."
            continue
        fi
    fi

    URL="$BASE_URL/${VER}/${NAME}"

    # Cek URL valid
    if ! check_url "$URL"; then
        echo "⚠️ URL not valid or unreachable for $NAME: $URL"
        continue
    fi

    # Install jika belum ada
    if [[ -f "$BIN_DIR/$NAME" ]]; then
        echo "$NAME already exists at $BIN_DIR/$NAME, skipping installation."
    else
        echo "Installing $NAME ${VER} into ${BIN_DIR}"
        if wget -q --show-progress -O "$BIN_DIR/$NAME" "$URL"; then
            chmod +x "$BIN_DIR/$NAME"
            echo "[DEBUG] $NAME installed at: $BIN_DIR/$NAME"
        else
            echo "⚠️ Failed to download $NAME from $URL"
            rm -f "$BIN_DIR/$NAME"
        fi
    fi

done

echo "✅ Preebuilt Installation complete."
