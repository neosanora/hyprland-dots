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
# Globals for tracking failures
# ----------------------------------------------------------

NOT_FOUND_PKGS=()

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

_inPacmanRepo() {
    local package="$1"
    if pacman -Si "$package" &>/dev/null; then
        return 0
    else
        return 1
    fi
}

# ----------------------------------------------------------
# Installers
# ----------------------------------------------------------

_installPacmanPackages() {
    local toInstall=()
    for pkg in "$@"; do
        if _isInstalled "${pkg}"; then
            echo ":: ${pkg} is already installed."
        elif _inPacmanRepo "${pkg}"; then
            toInstall+=("${pkg}")
        else
            NOT_FOUND_PKGS+=("${pkg}")
        fi
    done

    if [[ ${#toInstall[@]} -eq 0 ]]; then
        return 0
    fi

    echo "🔧 Menginstall package (pacman):"
    printf "%s\n" "${toInstall[@]}"

    sudo pacman -S --needed --noconfirm "${toInstall[@]}"
}

_installYay() {
    echo ":: Installing yay (build from AUR)..."
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
    local toInstall=()
    for pkg in "$@"; do
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
    printf "%s\n" "${toInstall[@]}"

    if [[ $(_checkCommandExists "yay") -eq 0 ]]; then
        yay --noconfirm -S --needed "${toInstall[@]}"
    else
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

if [[ $(_checkCommandExists "yay") -ne 0 ]]; then
    echo ":: yay not found. Will install yay when needed."
fi

if [[ ${#packages[@]} -gt 0 ]]; then
    _installPacmanPackages "${packages[@]}"
else
    echo ":: WARNING: Tidak ada isi array 'packages' dari arch.sh"
fi

if [[ ${#aur_packages[@]} -gt 0 ]]; then
    _installAURPackages "${aur_packages[@]}"
else
    echo ":: No additional AUR packages to install."
fi

if [ ! -d "$HOME/.local/bin" ]; then
    mkdir -p "$HOME/.local/bin"
fi

curl -s https://ohmyposh.dev/install.sh | bash -s -- -d ~/.local/bin

source "$SCRIPT_DIR/_prebuilt.sh" || true
source "$SCRIPT_DIR/_cursors.sh" || true
source "$SCRIPT_DIR/_fonts.sh" || true
source "$SCRIPT_DIR/_fontIcon.sh" || true
source "$SCRIPT_DIR/_ml4w-apps.sh" || true

echo
echo ":: Installation complete."
echo ":: Ready to install the dotfiles with the Dotfiles Installer."
echo ":: IF NOT, INSTALL GIT FIRST AND THEN RUN THE SCRIPT AGAIN."

if [[ ${#NOT_FOUND_PKGS[@]} -gt 0 ]]; then
    echo
    echo "⚠️  Summary: Paket berikut tidak ditemukan di repository pacman:"
    printf "%s\n" "${NOT_FOUND_PKGS[@]}"
fi
