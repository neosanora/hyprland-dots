#!/usr/bin/env bash
# --------------------------------------------------------------
# Arch Linux - NVIDIA Proprietary Driver Installer (Gaming Ready)
# Mirip archinstall: auto setup driver, kernel modules, grub update
# --------------------------------------------------------------

set -e

echo "[INFO] Updating system..."
sudo pacman -Syu --noconfirm

echo "[INFO] Installing NVIDIA proprietary drivers + dependencies..."
sudo pacman -S --noconfirm --needed \
    nvidia \
    nvidia-utils \
    nvidia-settings \
    lib32-nvidia-utils \
    vulkan-icd-loader \
    lib32-vulkan-icd-loader \
    opencl-nvidia \
    lib32-opencl-nvidia \
    mesa \
    lib32-mesa \
    vulkan-tools \
    lib32-vulkan-driver \
    egl-wayland

echo "[INFO] Adding NVIDIA modules to initramfs..."
sudo sed -i 's/^MODULES=(/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm /' /etc/mkinitcpio.conf

echo "[INFO] Rebuilding initramfs..."
sudo mkinitcpio -P

# --------------------------------------------------------------
# GRUB CONFIG UPDATE (safe merge)
# --------------------------------------------------------------
echo "[INFO] Checking GRUB config for NVIDIA DRM modeset..."

GRUB_CFG="/etc/default/grub"

# Tambah "nvidia-drm.modeset=1" ke GRUB_CMDLINE_LINUX_DEFAULT jika belum ada
if ! grep -q "nvidia-drm.modeset=1" "$GRUB_CFG"; then
    sudo sed -i 's/\(GRUB_CMDLINE_LINUX_DEFAULT=".*\)"/\1 nvidia-drm.modeset=1"/' "$GRUB_CFG"
    echo "[OK] Added nvidia-drm.modeset=1 to GRUB."
else
    echo "[OK] nvidia-drm.modeset=1 already exists in GRUB."
fi

echo "[INFO] Updating GRUB config..."
sudo grub-mkconfig -o /boot/grub/grub.cfg

echo "[INFO] NVIDIA proprietary driver installation complete!"
echo "[INFO] Please reboot to apply changes."
