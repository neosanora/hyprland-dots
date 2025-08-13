# ML4W Hyprland Starter 2.0

> [!IMPORTANT]
> These dotfiles are currently being revised and updated. This can lead to side effects during the installation or update.

![hyprland-starter20](https://github.com/user-attachments/assets/71e387ff-68a6-4c4d-a98c-6d6a86fb900e)

The ML4W Hyprland Starter package is the perfect starting point for your Hyprland customization experiments. The Hyprland Starter configuration works on all Linux distributions that support the dynamic tiling window manager Hyprland.

You can find configurations here: https://github.com/neosanora/my_hyprland-starter/tree/master/dotfiles

## Installation

You can install the ML4W Hyprland Starter easily with the Dotfiles Installer from an existing Window Manager or Desktop Environment.

<a href="https://mylinuxforwork.github.io/dotfiles-installer/" target="_blank"><img src="https://mylinuxforwork.github.io/dotfiles-installer/dotfiles-installer-badge.png" style="border:0;margin-bottom:10px"></a>

More information about the installation of the Dotfiles Installer here: https://github.com/mylinuxforwork/dotfiles-installer/wiki/01-Installation

**1**. Copy the following url into the Dotfiles Installer.

```
https://raw.githubusercontent.com/neosanora/my_hyprland-starter/master/hyprland-starter.dotinst
```


**0.1**. ...MANUAL... if you wonted to install it with old fasion way (manualy) not recomended!.

Just copy the following command into your terminal and execute.

```
bash <(curl -s https://raw.githubusercontent.com/neosanora/my_hyprland-starter/master/setup.sh)
```

**0.2** ...MANUAL... step 2 clone the Dotfile using git

```
git clone https://github.com/neosanora/my_hyprland-starter
```

**0.3** ...MANUAL... copy the all folder inside dotfile/.config/ to ~/.config



<details>
<summary>Please run the setup script offered by the Dotfiles Installer to install all dependencies. If your distribution is not supported,
please install the following dependencies manually:</summary>

- hyprland
- waybar
- rofi-wayland
- kitty
- dunst
- thunar
- xdg-desktop-portal-hyprland
- qt5-wayland
- qt6-wayland
- hyprpaper
- hyprlock
- firefox
- ttf-font-awesome
- vim
- fastfetch
- ttf-fira-sans
- ttf-fira-code
- ttf-firacode-nerd
- jq
- brightnessctl
- networkmanager
- wireplumber
</details>

> Hyprland does not officially support NVIDIA hardware. But many users have reported a successful installation. Please read: https://wiki.hyprland.org/Nvidia/

## Documentation (Wiki)

You can find the complete documentation of the ML4W Starter in the Wiki. <b>[Open the Wiki here](https://github.com/mylinuxforwork/hyprland-starter/wiki)</b>

## Dependencies

The script will install the following packages and the corresponding configurations:

- Window Manager: hyprland 
- Status Bar: waybar 
- Launcher: rofi-wayland 
- Browser: Firefox
- Terminal: kitty
- Notification Service: dunst 
- File Manager: Thunar
- xdg-desktop-portal-hyprland 
- qt5-wayland 
- qt6-wayland 
- Lock screen: hyprlock

## Key Bindings

The following custom key bindings are enabled (can be customized in ~/.config/hypr/hyprland.conf)

- <kbd>SUPER</kbd> + <kbd>RETURN</kbd> to start terminal
- <kbd>SUPER</kbd> + <kbd>Q</kbd> to quit an application
- <kbd>SUPER</kbd> + <kbd>B</kbd> to start browser
- <kbd>SUPER</kbd> + <kbd>M</kbd> to exit Hyprland
- <kbd>SUPER</kbd> + <kbd>E</kbd> to start filemanager
- <kbd>SUPER</kbd> + <kbd>SPACE</kbd> to start launcher rofi
- <kbd>SUPER</kbd> + <kbd>T</kbd> to toggle floating
- <kbd>SUPER</kbd> + <kbd>F</kbd> to toggle fullscreen
- <kbd>SUPER</kbd> + <kbd>1-9</kbd> to switch workspaces
- more key bindings in ~/.config/hypr/conf/binds.conf

or after the installation with right mouse click on Apps in the status bar.

## FAQ

<details>
<summary>Kitty terminal won't start in VirtualBox, what should I do?</summary>

**A:** This is a known issue when running Kitty in VirtualBox or other virtual machines, especially if GPU acceleration is limited or missing. Here are some steps you can try:

1. **Set environment variable before launching Kitty:**

   ```bash
   LIBGL_ALWAYS_SOFTWARE=true GALLIUM_DRIVER=llvmpipe kitty
   ```

   This forces Kitty to use software rendering instead of GPU.

2. **Install missing dependencies:**
   
   Make sure you have `mesa`, `libgl`, and `libx11` installed in your VM.

3. **Try launching from another terminal:**
   
   If Kitty fails to start, open another terminal like `xterm`, `alacritty`, or `foot` and try launching Kitty from there to see error messages.

4. **Check logs:**
   
   Run this command to see more detailed errors:

   ```bash
   kitty --debug-config
   ```

5. **Try running it under X11 instead of Wayland:**  
   Some VM environments are more compatible with X11.

---

**Still not working?**

If none of the above solutions work, we recommend using an alternative terminal emulator such as:

- `alacritty`
- `foot`
- `gnome-terminal`
- `xfce4-terminal`

They are lighter and more compatible in virtual machines.
</details>

## 🛠️ VirtualBox Troubleshooting (FAQ)

<details>
<summary>💥 Kitty terminal crashes in VirtualBox with a Wayland error</summary>

When launching `kitty` inside VirtualBox, you may encounter this error:

```
[glfw error 65544]: wayland: fatal display error: pipe wl_display#1: error 1: invalid arguments for wl_surface#31.attach
```

This happens because VirtualBox does not fully support GPU acceleration under Wayland, and `kitty` requires OpenGL.

### ✅ Solution:
Run `kitty` with software rendering:

```bash
LIBGL_ALWAYS_SOFTWARE=true GALLIUM_DRIVER=llvmpipe kitty
```

To make it permanent, you can:

- Add an alias in your `~/.bashrc` or `~/.zshrc`:

  ```bash
  alias kitty='LIBGL_ALWAYS_SOFTWARE=true GALLIUM_DRIVER=llvmpipe kitty'
  ```

- Or create a Hyprland keybind:

  ```ini
  bind = $mainMod, Q, exec, env LIBGL_ALWAYS_SOFTWARE=true GALLIUM_DRIVER=llvmpipe kitty
  ```

</details>

---

<details>
<summary>❌ Flatpak app fails to start with “Lost connection to Wayland compositor”</summary>

If you see this error:

```
Gdk-Message: Lost connection to Wayland compositor.
```

It usually means you are trying to run a Flatpak GUI app **outside of a Wayland session** (e.g., from a TTY or a broken desktop).

### ✅ Solution:

- Make sure you are inside a proper Wayland session:
  ```bash
  echo $WAYLAND_DISPLAY
  ```

  It should return something like `wayland-0` or `wayland-1`.

- Run Flatpak apps from a GUI terminal (like `kitty`, `foot`, or `gnome-terminal`) inside Hyprland or another Wayland compositor.

- If needed, manually specify the Wayland display:
  ```bash
  WAYLAND_DISPLAY=wayland-1 flatpak run com.ml4w.dotfilesinstaller
  ```

</details>

---

<details>
<summary>📦 How to enable VirtualBox Guest Additions in Arch Linux?</summary>

To enable features like dynamic resolution, clipboard sharing, and 3D acceleration:

### Install required packages:
```bash
sudo pacman -S virtualbox-guest-utils virtualbox-guest-dkms
```

### Enable the service:
```bash
sudo systemctl enable vboxservice --now
```

### Load kernel modules:
```bash
sudo modprobe -a vboxguest vboxsf vboxvideo
```

### Optional: Add user to vboxsf group (for shared folders)
```bash
sudo usermod -aG vboxsf $(whoami)
```

Then **reboot your system**.

</details>