
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