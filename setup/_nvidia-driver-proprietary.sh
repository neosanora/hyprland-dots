#!/usr/bin/env bash
# --------------------------------------------------------------
# Arch Linux - NVIDIA Proprietary Driver Installer (Minimal & Safe)
# --------------------------------------------------------------

set -e

echo "[INFO] Updating system..."
sudo pacman -Syu --noconfirm

# --------------------------------------------------------------
# Install NVIDIA drivers + utils
# --------------------------------------------------------------
PACKAGES=(
    nvidia
    nvidia-utils
    nvidia-settings
    lib32-nvidia-utils
    vulkan-icd-loader
    lib32-vulkan-icd-loader
    opencl-nvidia
    lib32-opencl-nvidia
    mesa
    lib32-mesa
    vulkan-tools
    egl-wayland
)

echo "[INFO] Installing NVIDIA proprietary drivers + dependencies..."
sudo pacman -S --noconfirm --needed "${PACKAGES[@]}"

# --------------------------------------------------------------
# Rebuild initramfs
# --------------------------------------------------------------
echo "[INFO] Rebuilding initramfs..."
sudo mkinitcpio -P

# --------------------------------------------------------------
# Update GRUB (optional: add DRM modeset if not exists)
# --------------------------------------------------------------
GRUB_CFG="/etc/default/grub"
if ! grep -q "nvidia-drm.modeset=1" "$GRUB_CFG"; then
    echo "[INFO] Adding nvidia-drm.modeset=1 to GRUB config..."
    sudo sed -i 's/\(GRUB_CMDLINE_LINUX_DEFAULT="[^"]*\)"/\1 nvidia-drm.modeset=1"/' "$GRUB_CFG"
fi

echo "[INFO] Regenerating GRUB config..."
sudo grub-mkconfig -o /boot/grub/grub.cfg

echo "[INFO] NVIDIA installation complete! Please reboot."
