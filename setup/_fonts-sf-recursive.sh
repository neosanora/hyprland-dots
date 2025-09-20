#!/usr/bin/env bash
# --------------------------------------------------------------
# otf font option wrapper (gum UI)
# --------------------------------------------------------------

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

INSTALL_SCRIPT="${1:-${SCRIPT_DIR}/options/install-sf-recursive.sh}"
INSTALL_SCRIPT=$(realpath -e "$INSTALL_SCRIPT" 2>/dev/null || realpath -m "$INSTALL_SCRIPT")

if [ ! -f "$INSTALL_SCRIPT" ]; then
    echo "Install script not found at: $INSTALL_SCRIPT"
    echo "Pass the path as first argument or place the install-sf-recursive.sh next to the main script."
    exit 1
fi

use_gum=0
if command -v gum >/dev/null 2>&1; then
    use_gum=1
fi

ask_confirm() {
    if [ "$use_gum" -eq 1 ]; then
        gum confirm \
            --affirmative "Yes" \
            --negative "No" \
            --default \
            "$1"
        return $?
    else
        while true; do
            read -r -p "$1 [y/N]: " ans
            case "$ans" in
                [Yy]|[Yy][Ee][Ss]) return 0 ;;
                [Nn]|[Nn][Oo]|"") return 1 ;;
                *) echo "Please answer y or n." ;;
            esac
        done
    fi
}

choose_editor() {
    if [ -n "${EDITOR:-}" ]; then
        echo "$EDITOR"
    elif command -v nano >/dev/null 2>&1; then
        echo "nano"
    elif command -v vi >/dev/null 2>&1; then
        echo "vi"
    else
        echo ""
    fi
}

# Offer to edit the FONTS array before running
if ask_confirm "Do you want to open the install script to review/edit the FONTS array before running?"; then
    editor=$(choose_editor)
    if [ -n "$editor" ]; then
        "$editor" "$INSTALL_SCRIPT"
    else
        echo "No editor found in EDITOR, and nano/vi not available. Skipping edit step."
    fi
fi

FLAGS=()

if [ "$use_gum" -eq 1 ]; then
    if ask_confirm "Run in dry-run mode (show what would happen)?"; then
        FLAGS+=("--dry-run")
    fi

    if ask_confirm "Install for user only (~/.local/share/fonts) (no sudo)?"; then
        FLAGS+=("--user")
    fi

    if ask_confirm "Keep the cloned repo after installation (--keep-repo)?"; then
        FLAGS+=("--keep-repo")
    fi

    cmd=("$INSTALL_SCRIPT" "${FLAGS[@]}")
    gum style --foreground=212 --border-foreground=236 --bold "Command to run:"
    printf '%q ' "${cmd[@]}" | gum format

    if ask_confirm "Run the command now?"; then
        bash "$INSTALL_SCRIPT" "${FLAGS[@]}"
    else
        echo "Aborted by user. No changes made."
        exit 0
    fi
else
    echo "gum not found — falling back to text prompts. Install 'gum' for a prettier UI: https://github.com/charmbracelet/gum"

    if ask_confirm "Run in dry-run mode (show what would happen)?"; then
        FLAGS+=("--dry-run")
    fi

    if ask_confirm "Install for user only (~/.local/share/fonts) (no sudo)?"; then
        FLAGS+=("--user")
    fi

    if ask_confirm "Keep the cloned repo after installation (--keep-repo)?"; then
        FLAGS+=("--keep-repo")
    fi

    echo "About to run: $INSTALL_SCRIPT ${FLAGS[*]}"
    if ask_confirm "Run the command now?"; then
        bash "$INSTALL_SCRIPT" "${FLAGS[@]}"
    else
        echo "Aborted by user. No changes made."
        exit 0
    fi
fi

exit 0
