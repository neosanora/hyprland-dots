#!/usr/bin/env bash

# ----------------------------------------------------------
# Packages installer (split pacman vs AUR/yay functions)
# ----------------------------------------------------------

set -euo pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source "$SCRIPT_DIR/share/packages/arch.sh"

# Source AUR package list
AUR_PKG_FILE="$SCRIPT_DIR/share/aur/aur-package.sh"
if [[ -f "$AUR_PKG_FILE" ]]; then
    source "$AUR_PKG_FILE"
else
    echo ":: WARNING: File aur-package.sh tidak ditemukan. Lewati AUR tambahan."
    aur_packages=()
fi

# Download folder untuk yay
download_folder="$SCRIPT_DIR/tmp"
mkdir -p "$download_folder"

# --------------------------------------------------------------
# Library
# --------------------------------------------------------------

source "$SCRIPT_DIR/_lib.sh"

# ----------------------------------------------------------
# Helpers
# ----------------------------------------------------------

_isInstalled() {
    local package="$1"
    if pacman -Qq "${package}" &>/dev/null; then
        return 0
    else
        return 1
    fi
}

# ----------------------------------------------------------
# Installers
# ----------------------------------------------------------

_installPacmanPackages() {
    # Usage: _installPacmanPackages pkg1 pkg2 ...
    local toInstall=()
    for pkg in "$@"; do
        if _isInstalled "${pkg}"; then
            echo ":: ${pkg} is already installed."
        else
            toInstall+=("${pkg}")
        fi
    done

    if [[ ${#toInstall[@]} -eq 0 ]]; then
        return 0
    fi

    echo "🔧 Menginstall package (pacman):"
    printf "%s
" "${toInstall[@]}"

    sudo pacman -S --needed --noconfirm "${toInstall[@]}"
}

_installYay() {
    # install base dependencies and build yay if not present
    echo ":: Installing yay (build from AUR)..."
    # ensure base-devel + git present
    _installPacmanPackages base-devel git

    local script_path
    script_path=$(realpath "$0")
    local temp_path
    temp_path=$(dirname "$script_path")

    local yay_dir="$download_folder/yay"
    rm -rf "$yay_dir"
    git clone https://aur.archlinux.org/yay.git "$yay_dir"
    pushd "$yay_dir" >/dev/null || exit 1
    makepkg --noconfirm -si
    popd >/dev/null || true

    echo ":: yay has been installed successfully."
}

_installAURPackages() {
    # Usage: _installAURPackages pkg1 pkg2 ...
    local toInstall=()
    for pkg in "$@"; do
        # If already installed by pacman or yay, skip
        if _isInstalled "${pkg}"; then
            echo ":: ${pkg} is already installed."
            continue
        fi
        toInstall+=("${pkg}")
    done

    if [[ ${#toInstall[@]} -eq 0 ]]; then
        return 0
    fi

    echo "🔧 Menginstall package (AUR/yay):"
    printf "%s
" "${toInstall[@]}"

    if [[ $(_checkCommandExists "yay") -eq 0 ]]; then
        yay --noconfirm -S --needed "${toInstall[@]}"
    else
        # if yay tidak tersedia, build lalu gunakan
        _installYay
        yay --noconfirm -S --needed "${toInstall[@]}"
    fi
}

# --------------------------------------------------------------
# Install Gum (utility used by installer)
# --------------------------------------------------------------

if [[ $(_checkCommandExists "gum") -eq 0 ]]; then
    echo ":: gum is already installed"
else
    echo ":: The installer requires gum. gum will be installed now"
    sudo pacman --noconfirm -S gum
fi

# --------------------------------------------------------------
# Header
# --------------------------------------------------------------

_writeHeader "Arch"

# ----------------------------------------------------------
# Main flow
# ----------------------------------------------------------

# Ensure yay is present before attempting AUR jobs later
if [[ $(_checkCommandExists "yay") -ne 0 ]]; then
    echo ":: yay not found. Will install yay when needed."
fi

# Install packages from arch.sh (pacman packages)
if [[ ${#packages[@]} -gt 0 ]]; then
    _installPacmanPackages "${packages[@]}"
else
    echo ":: WARNING: Tidak ada isi array 'packages' dari arch.sh"
fi

# Install additional AUR packages
if [[ ${#aur_packages[@]} -gt 0 ]]; then
    _installAURPackages "${aur_packages[@]}"
else
    echo ":: No additional AUR packages to install."
fi

# --------------------------------------------------------------
# Create .local/bin folder
# --------------------------------------------------------------

if [ ! -d "$HOME/.local/bin" ]; then
    mkdir -p "$HOME/.local/bin"
fi

# --------------------------------------------------------------
# Oh My Posh
# --------------------------------------------------------------

curl -s https://ohmyposh.dev/install.sh | bash -s -- -d ~/.local/bin

# --------------------------------------------------------------
# Prebuilt Packages
# --------------------------------------------------------------

source "$SCRIPT_DIR/_prebuilt.sh" || true

# --------------------------------------------------------------
# Cursors
# --------------------------------------------------------------

source "$SCRIPT_DIR/_cursors.sh" || true

# --------------------------------------------------------------
# Fonts
# --------------------------------------------------------------

source "$SCRIPT_DIR/_fonts.sh" || true

# --------------------------------------------------------------
# Font Icons
# --------------------------------------------------------------

source "$SCRIPT_DIR/_fontIcon.sh" || true

# --------------------------------------------------------------
# ml4w apps
# --------------------------------------------------------------

source "$SCRIPT_DIR/_ml4w-apps.sh" || true

# ----------------------------------------------------------
# Done
# ----------------------------------------------------------

echo
echo ":: Installation complete."
echo ":: Ready to install the dotfiles with the Dotfiles Installer."
echo ":: IF NOT, INSTALL GIT FIRST AND THEN RUN THE SCRIPT AGAIN."
