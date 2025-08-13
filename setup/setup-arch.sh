#!/usr/bin/env bash

# ----------------------------------------------------------
# Packages
# ----------------------------------------------------------

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source "$SCRIPT_DIR/share/packages/arch.sh"

# Source AUR package list
AUR_PKG_FILE="$SCRIPT_DIR/share/packages/aur-package.sh"
if [[ -f "$AUR_PKG_FILE" ]]; then
    source "$AUR_PKG_FILE"
else
    echo ":: WARNING: File aur-package.sh tidak ditemukan. Lewati AUR tambahan."
    aur_packages=()
fi

# Download folder untuk yay
download_folder="$SCRIPT_DIR/tmp"
mkdir -p "$download_folder"

# ----------------------------------------------------------
# Colors
# ----------------------------------------------------------

GREEN='\033[0;32m'
NONE='\033[0m'

# ----------------------------------------------------------
# Utils
# ----------------------------------------------------------

_checkCommandExists() {
    cmd="$1"
    if ! command -v "$cmd" >/dev/null; then
        echo 1
        return
    fi
    echo 0
}

_isInstalled() {
    package="$1"
    if pacman -Qq "${package}" &>/dev/null; then
        echo 0
    else
        echo 1
    fi
}

_installYay() {
    _installPackages "base-devel"
    SCRIPT=$(realpath "$0")
    temp_path=$(dirname "$SCRIPT")
    git clone https://aur.archlinux.org/yay.git "$download_folder/yay"
    cd "$download_folder/yay" || exit
    makepkg --noconfirm -si
    cd "$temp_path" || exit
    echo ":: yay has been installed successfully."
}

_installPackages() {
    toInstall=()
    for pkg; do
        if [[ $(_isInstalled "${pkg}") == 0 ]]; then
            echo ":: ${pkg} is already installed."
            continue
        fi
        toInstall+=("${pkg}")
    done

    if [[ "${#toInstall[@]}" -eq 0 ]]; then
        return
    fi

    echo "🔧 Menginstall package berikut:"
    printf "%s\n" "${toInstall[@]}"

    if [[ $(_checkCommandExists "yay") == 0 ]]; then
        yay --noconfirm -S "${toInstall[@]}"
    else
        # Gunakan pacman untuk package dasar jika yay belum ada
        sudo pacman -S --needed --noconfirm "${toInstall[@]}"
    fi
}


# _installPackages() {
#     toInstall=()
#     for pkg; do
#         if [[ $(_isInstalled "${pkg}") == 0 ]]; then
#             echo ":: ${pkg} is already installed."
#         else
#             toInstall+=("${pkg}")
#         fi
#     done
#     if [[ "${#toInstall[@]}" -eq 0 ]]; then
#         return
#     fi
#     printf "🔧 Menginstall package berikut:\n%s\n" "${toInstall[@]}"
#     yay --noconfirm -S "${toInstall[@]}"
# }

# ----------------------------------------------------------
# Header
# ----------------------------------------------------------

clear
echo -e "${GREEN}"
cat <<"EOF"
   ____    __          
  / __/__ / /___ _____ 
 _\ \/ -_) __/ // / _ \
/___/\__/\__/\_,_/ .__/
                /_/    
ML4W Hyprland Starter for Arch based distros
EOF
echo -e "${NONE}"

# ----------------------------------------------------------
# Prompt
# ----------------------------------------------------------

AUTO_YES=0
if [[ "$1" == "--yes" ]]; then
    AUTO_YES=1
fi

if [[ $AUTO_YES -eq 0 ]]; then
    while true; do
        read -rp "DO YOU WANT TO START THE PACKAGE INSTALLATION NOW? (Yy/Nn): " yn
        case $yn in
            [Yy]*)
                echo ":: Installation started."
                echo
                break
                ;;
            [Nn]*)
                echo ":: Installation canceled"
                exit
                ;;
            *)
                echo ":: Please answer yes or no."
                ;;
        esac
    done
else
    echo ":: Auto mode enabled. Starting installation."
fi

# ----------------------------------------------------------
# Main
# ----------------------------------------------------------

# -------------------------------------------------------------
# Install yay if not found
# -------------------------------------------------------------
if [[ $(_checkCommandExists "yay") == 0 ]]; then
    echo ":: yay is already installed"
else
    echo ":: The installer requires yay. Installing yay now..."
    _installYay
fi

# --------------------------------------------------------------
# Install packages from arch.sh
# --------------------------------------------------------------
if [[ ${#packages[@]} -gt 0 ]]; then
    _installPackages "${packages[@]}"
else
    echo ":: WARNING: Tidak ada isi array 'packages' dari arch.sh"
fi

# --------------------------------------------------------------
# Install additional AUR packages
# --------------------------------------------------------------
if [[ ${#aur_packages[@]} -gt 0 ]]; then
    echo ":: Installing additional AUR packages from aur-package.sh..."
    _installPackages "${aur_packages[@]}"
else
    echo ":: No additional AUR packages to install."
fi

# --------------------------------------------------------------
# Create .local/bin folder
# --------------------------------------------------------------

if [ ! -d $HOME/.local/bin ]; then
    mkdir -p $HOME/.local/bin
fi

# --------------------------------------------------------------
# Oh My Posh
# --------------------------------------------------------------

curl -s https://ohmyposh.dev/install.sh | bash -s -- -d ~/.local/bin

# --------------------------------------------------------------
# Prebuilt Packages
# --------------------------------------------------------------

source $SCRIPT_DIR/_prebuilt.sh

# ----------------------------------------------------------
# Done
# ----------------------------------------------------------

echo
echo ":: Installation complete."
echo ":: Ready to install the dotfiles with the Dotfiles Installer."
echo ":: IF NOT, INSTALL GIT FIRST AND THEN RUN THE CRIPT AGAIN."