#!/usr/bin/env bash
# Minimal script: install NVIDIA driver + lib32 utils + headers + Mesa & Vulkan
# - Regenerates initramfs
# - Adds kernel parameter nvidia-drm.modeset=1 to GRUB (if GRUB is used)
# Review before running. Run as root (sudo).

set -euo pipefail
IFS=$'
	'

PACMAN_OPTS=(--noconfirm --needed)
PKGS=(
  nvidia
  nvidia-utils
  lib32-nvidia-utils
  nvidia-settings
  linux-headers
  mesa
  vulkan-icd-loader
  lib32-vulkan-icd-loader
  vulkan-tools
)

GRUB_FILE="/etc/default/grub"
BACKUP_DIR="/root/arch-nvidia-backups-$(date +%s)"

if [[ $EUID -ne 0 ]]; then
  echo "Error: please run this script as root (sudo)." >&2
  exit 1
fi

echo "== Minimal NVIDIA + Mesa/Vulkan installer for Arch =="

# Update system
echo "-> Updating package database and system (pacman -Syu)"
pacman -Syu "${PACMAN_OPTS[@]}"

# Install packages
echo "-> Installing packages: ${PKGS[*]}"
pacman -S "${PACMAN_OPTS[@]}" "${PKGS[@]}"

# Regenerate initramfs
if command -v mkinitcpio >/dev/null 2>&1; then
  echo "-> Regenerating initramfs (mkinitcpio -P)"
  mkinitcpio -P
else
  echo "-> mkinitcpio not found; skip initramfs regeneration." >&2
fi

# Update GRUB kernel parameter if GRUB exists
if [[ -f "$GRUB_FILE" ]]; then
  echo "-> Backing up $GRUB_FILE to $BACKUP_DIR"
  mkdir -p "$BACKUP_DIR"
  cp "$GRUB_FILE" "$BACKUP_DIR/"

  if grep -q "nvidia-drm.modeset=1" "$GRUB_FILE"; then
    echo "-> GRUB already contains nvidia-drm.modeset=1; skipping edit."
  else
    echo "-> Adding nvidia-drm.modeset=1 to GRUB_CMDLINE_LINUX_DEFAULT"
    sed -i '/^GRUB_CMDLINE_LINUX_DEFAULT=/ s/"$/ nvidia-drm.modeset=1"/' "$GRUB_FILE"
    echo "-> Regenerating grub config (if grub-mkconfig is available)"
    if command -v grub-mkconfig >/dev/null 2>&1; then
      grub-mkconfig -o /boot/grub/grub.cfg
    else
      echo "-> grub-mkconfig not found; remember to update your bootloader config manually." >&2
    fi
  fi
else
  echo "-> GRUB not detected (/etc/default/grub missing). Please add 'nvidia-drm.modeset=1' to your bootloader kernel command line manually if needed." >&2
fi

cat <<EOF

Done.
- NVIDIA drivers + lib32 utils + linux-headers + Mesa & Vulkan installed.
- initramfs regenerated (if mkinitcpio present).
- If GRUB detected, kernel cmdline updated and grub.cfg regenerated (backup stored in $BACKUP_DIR).

Notes:
- 'mesa' provides OpenGL/EGL implementations used by many Linux apps. Even with NVIDIA driver, mesa is commonly needed for compatibility and fallbacks.
- 'vulkan-icd-loader' + 'lib32-vulkan-icd-loader' enable Vulkan support for native and 32-bit games (Steam Proton).
- If you use linux-lts or a custom kernel, replace linux-headers with the matching headers (e.g. linux-lts-headers).
- Review the GRUB backup in $BACKUP_DIR before rebooting.
EOF

exit 0
