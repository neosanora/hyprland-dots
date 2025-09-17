#!/usr/bin/env bash
#  ____  _          _ _
# / ___|| |__   ___| | |
# \___ \| '_ \ / _ \ | |
#  ___) | | | |  __/ | |
# |____/|_| |_|\___|_|_|
#

set -euo pipefail

# Pastikan figlet & gum tersedia
for cmd in figlet gum; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "ERROR: $cmd not found. Please install it first."
        exit 1
    fi
done

sleep 1
clear
figlet -f smslant "Shell"

echo ":: Please select your preferred shell"
echo
shell=$(gum choose "bash" "zsh" "fish" "Cancel")

# -----------------------------------------------------
# Function: change shell safely
# -----------------------------------------------------
change_shell() {
    local sh_bin
    sh_bin="$(command -v "$1" || true)"

    if [[ -z "$sh_bin" ]]; then
        echo "ERROR: $1 not found in PATH."
        exit 1
    fi

    if ! grep -qx "$sh_bin" /etc/shells; then
        echo "ERROR: $sh_bin is not listed in /etc/shells"
        echo "Add it manually or install properly before retrying."
        exit 1
    fi

    while ! chsh -s "$sh_bin"; do
        echo "ERROR: Authentication failed. Please enter the correct password."
        sleep 1
    done
    echo ":: Shell is now $1 ($sh_bin)."
}

# -----------------------------------------------------
# Function: install oh-my-posh if missing
# -----------------------------------------------------
install_omp() {
    if ! command -v oh-my-posh >/dev/null 2>&1; then
        echo ":: Installing oh-my-posh"
        curl -s https://ohmyposh.dev/install.sh | bash -s
    else
        echo ":: oh-my-posh already installed"
    fi
}

# -----------------------------------------------------
# Activate bash
# -----------------------------------------------------
if [[ $shell == "bash" ]]; then
    change_shell bash
    install_omp
    gum spin --spinner dot --title "Please reboot your system." -- sleep 3

# -----------------------------------------------------
# Activate fish
# -----------------------------------------------------
elif [[ $shell == "fish" ]]; then
    echo ":: Please install fish manually for your distro (if not yet done) before proceeding."
    if gum confirm "Is fish installed on your system?"; then
        change_shell fish
        install_omp
        gum spin --spinner dot --title "Please reboot your system." -- sleep 3
    fi

# -----------------------------------------------------
# Activate zsh
# -----------------------------------------------------
elif [[ $shell == "zsh" ]]; then
    change_shell zsh
    install_omp

    # Installing oh-my-zsh
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        echo ":: Installing oh-my-zsh"
        sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        cp ~/.config/ml4w/tpl/.zshrc ~/
    else
        echo ":: oh-my-zsh already installed"
    fi

    # Installing plugins
    ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}

    for plugin in \
        "zsh-users/zsh-autosuggestions" \
        "zsh-users/zsh-syntax-highlighting" \
        "zdharma-continuum/fast-syntax-highlighting"
    do
        name=$(basename "$plugin")
        if [ ! -d "$ZSH_CUSTOM/plugins/$name" ]; then
            echo ":: Installing $name"
            git clone "https://github.com/$plugin.git" "$ZSH_CUSTOM/plugins/$name"
        else
            echo ":: $name already installed"
        fi
    done

    gum spin --spinner dot --title "Please reboot your system." -- sleep 3

# -----------------------------------------------------
# Cancel
# -----------------------------------------------------
else
    echo ":: Changing shell canceled"
    exit 0
fi
