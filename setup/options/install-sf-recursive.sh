#!/usr/bin/env bash

set -euo pipefail

# --- UBAH HANYA BARIS INI (tambah/hapus nama folder sesuai repo) ---
FONTS=("SF Pro" "SF Serif" "SF Mono")
# -----------------------------------------------------------------

# Default lokasi kerja dan tujuan (ubah dengan --user untuk user-only)
FONT_DIR="/tmp/San-Francisco-family"
SYSTEM_FONT_LOCATION="/usr/local/share/fonts/opentype"
FONT_URL="https://github.com/thelioncape/San-Francisco-family.git"

DRY_RUN=0
USER_ONLY=0
KEEP_REPO=0

print_usage() {
    cat <<'USAGE'
Usage: install-sf-recursive.sh [--dry-run] [--user] [--keep-repo] [--help]

Options:
  --dry-run      Show what would be copied (no files changed)
  --user         Install to the current user's font folder (~/.local/share/fonts) (no sudo)
  --keep-repo    Keep the cloned repository in $FONT_DIR after the script finishes
                 If the repo already exists and --keep-repo is specified, it will be reused (no reclone).
  --help         Show this help

Notes:
  - Edit only the FONTS=(...) array to add/remove font folders to copy.
  - The script will first try a sparse/partial clone; if that fails it falls back to a normal shallow clone.
  - In non--user mode the script will use sudo for creating dirs and copying files.
USAGE
}

# --- Parse args ---
while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run)
            DRY_RUN=1; shift ;;
        --user)
            USER_ONLY=1; shift ;;
        --keep-repo)
            KEEP_REPO=1; shift ;;
        --help)
            print_usage; exit 0 ;;
        *)
            echo "Unknown arg: $1" >&2; print_usage; exit 1 ;;
    esac
done

if [ "$USER_ONLY" -eq 1 ]; then
    SYSTEM_FONT_LOCATION="$HOME/.local/share/fonts"
    SUDO_CMD=""
else
    SUDO_CMD="sudo"
fi

lower_and_slugify() {
    printf "%s" "$1" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g' | sed -E 's/^-|-$//g'
}

require_cmd() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "Required command '$1' not found. Please install it." >&2
        exit 1
    fi
}

require_cmd git
require_cmd find
require_cmd sed

clone_repo() {
    echo "### Cloning repo (attempt sparse/partial clone first)..."

    # If the repo already exists and user requested to keep/reuse it, just reuse it
    if [ -d "$FONT_DIR" ] && [ "$KEEP_REPO" -eq 1 ]; then
        if [ -d "$FONT_DIR/.git" ]; then
            echo "Using existing repository at $FONT_DIR (KEEP_REPO enabled)."
            cd "$FONT_DIR" || { echo "Failed to enter $FONT_DIR"; return 1; }
            git fetch --all --prune || true
            return 0
        else
            echo "Directory $FONT_DIR exists but doesn't look like a git repo. It will be replaced."
            rm -rf "$FONT_DIR"
        fi
    else
        # remove any existing dir to ensure a clean clone
        if [ -d "$FONT_DIR" ]; then
            rm -rf "$FONT_DIR"
        fi
    fi

    # Try sparse/partial clone (fast) --- some git versions or servers may not support it
    if git clone -n --depth=1 --filter=tree:0 "$FONT_URL" "$FONT_DIR" 2>/dev/null; then
        cd "$FONT_DIR" || { echo "Failed to enter $FONT_DIR"; return 1; }
        if git sparse-checkout init --no-cone 2>/dev/null && git sparse-checkout set "${FONTS[@]}" 2>/dev/null && git checkout 2>/dev/null; then
            echo "Sparse checkout succeeded. Using partial clone."
            return 0
        else
            echo "Sparse checkout failed after partial clone. Will fallback."
        fi
    else
        echo "Partial clone with filter=tree:0 failed. Will fallback to normal shallow clone."
    fi

    # Fallback: full shallow clone (shallower but heavier)
    echo "### Fallback: doing normal shallow clone -- this may download more data..."
    rm -rf "$FONT_DIR"
    git clone --depth=1 "$FONT_URL" "$FONT_DIR"
    cd "$FONT_DIR" || { echo "Failed to enter $FONT_DIR"; return 1; }
    return 0
}

copy_recursive() {
    echo "### Copying fonts recursively..."

    for font in "${FONTS[@]}"; do
        src_dir="$FONT_DIR/$font"
        if [ ! -d "$src_dir" ]; then
            echo "Warning: source folder not found for '$font' (skipping)"
            continue
        fi

        dest_name=$(lower_and_slugify "$font")
        target_dir="$SYSTEM_FONT_LOCATION/$dest_name"

        echo "-> Font: '$font'  (source: $src_dir)"

        # find all .otf and .ttf files recursively
        mapfile -d $'' -t files < <(find "$src_dir" -type f \( -iname '*.otf' -o -iname '*.ttf' \) -print0)

        if [ ${#files[@]} -eq 0 ]; then
            echo "   Warning: no .otf/.ttf files found for '$font'"
            continue
        fi

        for file in "${files[@]}"; do
            # compute relative path inside font folder
            rel_path="${file#$src_dir/}"
            rel_dir="$(dirname -- "$rel_path")"
            if [ "$rel_dir" = "." ]; then
                dest_path="$target_dir"
            else
                dest_path="$target_dir/$rel_dir"
            fi

            if [ "$DRY_RUN" -eq 1 ]; then
                echo "   [dry-run] Would create dir: $dest_path"
                echo "   [dry-run] Would copy: $rel_path -> $dest_path/"
            else
                if [ -n "$SUDO_CMD" ]; then
                    $SUDO_CMD mkdir -p "$dest_path"
                    $SUDO_CMD cp -- "$file" "$dest_path/"
                else
                    mkdir -p "$dest_path"
                    cp -- "$file" "$dest_path/"
                fi
                echo "   Copied: $rel_path -> $dest_path/"
            fi
        done
    done

    if [ "$DRY_RUN" -eq 1 ]; then
        echo "### dry-run complete: no files were changed."
    else
        echo "### Updating font cache..."
        if [ -n "$SUDO_CMD" ]; then
            $SUDO_CMD fc-cache -fv
        else
            fc-cache -fv
        fi
        echo "### Done!"
    fi
}

# --- main ---
clone_repo
copy_recursive

# cleanup repo unless user asked to keep it
if [ "$KEEP_REPO" -eq 0 ]; then
    if [ -d "$FONT_DIR" ]; then
        rm -rf "$FONT_DIR"
        echo "Removed temporary repo: $FONT_DIR"
    fi
else
    echo "Keeping repository at: $FONT_DIR"
fi