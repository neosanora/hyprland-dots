#!/usr/bin/env bash
# --------------------------------------------------------------
# Download and Install Bibata Cursors + Manual Cursors
# --------------------------------------------------------------

# Set variables
download_folder="$HOME/Downloads/bibata-cursors"
bibata_url="https://github.com/ful1e5/Bibata_Cursor/releases/download/v2.0.7"
icons_dir="$HOME/.local/share/icons"

# Create fresh download folder
rm -rf "$download_folder"
mkdir -p "$download_folder"

# Download Bibata cursor themes
for theme in Amber Classic Ice; do
    wget -q --show-progress -P "$download_folder" "$bibata_url/Bibata-Modern-$theme.tar.xz"
done

# Ensure icons directory exists
mkdir -p "$icons_dir"

# Remove old Bibata installations
for theme in Amber Classic Ice; do
    rm -rf "$icons_dir/Bibata-Modern-$theme"
done

# Extract Bibata themes
tar -xf "$download_folder/Bibata-Modern-Amber.tar.xz"   -C "$icons_dir"
tar -xf "$download_folder/Bibata-Modern-Classic.tar.xz" -C "$icons_dir"
tar -xf "$download_folder/Bibata-Modern-Ice.tar.xz"     -C "$icons_dir"

# --------------------------------------------------------------
# Manual extract custom cursors
# --------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for cursor_archive in \
    "ComixCursors-0.10.1.tar.bz2" \
    "oreo-spark-dark-cursors.tar.gz" \
    "oreo-spark-purple-cursors.tar.gz"; do
    tar -xf "$SCRIPT_DIR/cursors/$cursor_archive" -C "$icons_dir"
done

echo "✅ Cursor themes installed successfully."
