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