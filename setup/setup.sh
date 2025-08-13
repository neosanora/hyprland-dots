#!/bin/bash
sleep 1

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

_checkCommandExists() {
    cmd="$1"
    if ! command -v "$cmd" >/dev/null; then
        echo 1
        return
    fi
    echo 0
    return
}

_selectDistribution() {

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
ML4W Hyprland Starter

EOF
    echo -e "${NONE}"
    
    echo ":: Distribution could not be auto detected. Please select your base distribution."
    echo 
    echo "1: Arch (pacman + aur helper)"
    echo "2: Fedora (dnf)"
    echo "4: OpenSuse (zypper)"
    echo "5: Show dependencies and install manually for your distribution"
    echo "6: Cancel"
    echo 
    while true; do
        read -p "Plase select: " yn
        case $yn in
            1)
                $SCRIPT_DIR/setup-arch.sh
                break
                ;;
            2)
                $SCRIPT_DIR/setup-fedora.sh
                break
                ;;
            4)
                $SCRIPT_DIR/setup-opensuse.sh
                break
                ;;
            5)
                $SCRIPT_DIR/dependencies.sh
                break
                ;;
            6)
                echo ":: Installation canceled"
                exit
                break
                ;;
            *)
                echo ":: Please select a valid option."
                ;;
        esac
    done    
    }

if [[ $(_checkCommandExists "pacman") == 0 ]]; then
    "$SCRIPT_DIR/setup-arch.sh"
elif [[ $(_checkCommandExists "dnf") == 0 ]]; then
    "$SCRIPT_DIR/setup-fedora.sh"
elif [[ $(_checkCommandExists "zypper") == 0 ]]; then
    $SCRIPT_DIR/setup-opensuse.sh
else
    bash "$SCRIPT_DIR/dependencies.sh"
fi