#!/usr/bin/env bash
# --------------------------------------------------------------
# Auto Download & Install Prebuilt Binaries (OS/Arch Aware)
# Supports GitHub releases (multi-asset) + fixed URL
# Extracts archives automatically (.tar.gz / .zip)
# --------------------------------------------------------------

set -e
BIN_DIR="$HOME/.local/bin"
TMP_DIR="/tmp/prebuilt-installer"
mkdir -p "$BIN_DIR" "$TMP_DIR"

# --------------------------------------------------------------
# Package List (format: "name|repo_api|fixed_url")
# - name      : nama binary
# - repo_api  : GitHub API repo releases (kosongkan kalau fixed URL)
# - fixed_url : URL langsung (opsional, kalau tidak pakai GitHub API)
# --------------------------------------------------------------
PACKAGES=(
  "matugen|https://api.github.com/repos/InioX/matugen/releases|"
)

# --------------------------------------------------------------
# Function: fetch latest release asset from GitHub
# --------------------------------------------------------------
get_latest_asset() {
  local api_url="$1"
  local name="$2"
  local os="$(uname -s | tr '[:upper:]' '[:lower:]')"
  local arch="$(uname -m)"

  # normalize arch
  case "$arch" in
    x86_64) arch="amd64|x86_64" ;;
    aarch64) arch="arm64|aarch64" ;;
  esac

  curl -s "$api_url/latest" | jq -r \
    ".assets[] | select(.name | test(\"$os.*($arch)\")) | .browser_download_url" | head -n 1
}

# --------------------------------------------------------------
# Function: check URL
# --------------------------------------------------------------
check_url() {
  local url="$1"
  curl -fsIL "$url" >/dev/null 2>&1
}

# --------------------------------------------------------------
# Function: install binary
# --------------------------------------------------------------
install_binary() {
  local name="$1"
  local url="$2"

  [[ -z "$url" ]] && echo "⚠️  No valid asset URL found for $name" && return

  if [[ -f "$BIN_DIR/$name" ]]; then
    echo "✅ $name already exists, skipping."
    return
  fi

  echo "⬇️  Downloading $name from $url"
  local tmpfile="$TMP_DIR/$(basename "$url")"
  if ! curl -L --progress-bar -o "$tmpfile" "$url"; then
    echo "⚠️  Failed to download $name"
    return
  fi

  # extract if archive
  if [[ "$tmpfile" =~ \.tar\.gz$ ]]; then
    tar -xzf "$tmpfile" -C "$TMP_DIR"
    local binpath
    binpath=$(find "$TMP_DIR" -type f -name "$name" | head -n 1)
    [[ -n "$binpath" ]] && mv "$binpath" "$BIN_DIR/$name"
  elif [[ "$tmpfile" =~ \.zip$ ]]; then
    unzip -qo "$tmpfile" -d "$TMP_DIR"
    local binpath
    binpath=$(find "$TMP_DIR" -type f -name "$name" | head -n 1)
    [[ -n "$binpath" ]] && mv "$binpath" "$BIN_DIR/$name"
  else
    mv "$tmpfile" "$BIN_DIR/$name"
  fi

  chmod +x "$BIN_DIR/$name"
  echo "✅ Installed $name at $BIN_DIR/$name"
}

# --------------------------------------------------------------
# Main Loop
# --------------------------------------------------------------
for pkg in "${PACKAGES[@]}"; do
  IFS="|" read -r NAME API_URL FIXED_URL <<< "$pkg"

  echo "-----------------------------"
  echo "📦 Processing: $NAME"
  echo "-----------------------------"

  if [[ -n "$API_URL" ]]; then
    ASSET_URL=$(get_latest_asset "$API_URL" "$NAME")
    install_binary "$NAME" "$ASSET_URL"
  elif [[ -n "$FIXED_URL" ]]; then
    install_binary "$NAME" "$FIXED_URL"
  else
    echo "⚠️  No source defined for $NAME, skipping."
  fi
done

echo "🎉 All installations complete."
