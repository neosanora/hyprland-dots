#!/usr/bin/env bash

# ============================================
# 🎯 Daftar Package
# ============================================

packages=(
  #////////////////////#
  ### |    Tools   | ###
  #////////////////////#
  "pacman-contrib"  # Contributed scripts and tools for pacman systems
  "imagemagick"     # Software suite to create, edit, compose, or convert bitmap images
  "tumbler"         # Thumbnail service implementing the thumbnail management D-Bus specification
  "gvfs"            # Virtual filesystem implementation for GIO
  "inotify-tools"   # inotify-tools is a C library and a set of command-line programs for Linux providing a simple interface to inotify.
  ###  can be execute ###
  "gammastep"       # Adjust the color temperature of your screen according to your surroundings.
  "cliphist"        # wayland clipboard manager
  "unzip"           # For extracting and viewing files in .zip archives
  "cpio"            # A tool to copy files into or out of a cpio or tar archive
  "xclip"           # Command line interface to the X11 clipboard
  "figlet"          # A program for making large letters out of ordinary text
  "git"             # version control
  "jq"              # JSON processor
  "gum"             # command line UI toolkit
  "fastfetch"       # system information tool
  "yt-dlp"          # A youtube-dl fork with additional features and fixes
 ### have GUI ###
  "loupe"           # A simple image viewer for GNOME

  #//////////////#
  # |  PYTHON  | #
  #//////////////#
  "python-pip"      # The PyPA recommended tool for installing Python packages
  "python-gobject"  # Python bindings for GLib/GObject/GIO/GTK

  #//////////////#
  ### | APPS | ###
  #//////////////#
  "firefox"         # Browser
  "nautilus"        # Default file manager for GNOME

  #/////////////////////#
  ### | File Editor | ###
  #/////////////////////#
  "vim"             # Vi Improved, a highly configurable, improved version of the vi text editor
  "neovim"          # Fork of Vim aiming to improve user experience, plugins, and GUIs

  #//////////////////////#
  ### | File Manager | ###
  #//////////////////////#
  "ranger"          # Simple, vim-like file manager
  "thunar"          # Modern, fast and easy-to-use file manager for Xfce

  #/////////////////////#
  ### | App Manager | ###
  #/////////////////////#
  "flatpak"         # Alternatif package manager (sandboxed)

  #///////////////#
  ### | THEME | ###
  #///////////////#
  "kvantum"             # SVG-based theme engine for Qt6 (including config tool and extra themes)
  "qt6ct"               # Qt 6 Configuration Utility
  "nwg-look"            # GTK settings editor adapted to work on wlroots-based compositors
  ### widget theme ###
  "adw-gtk-theme"       # Unofficial GTK 3 port of the libadwaita theme
  "adapta-gtk-theme"    # Adapta is a material design-inspired
  "breeze"              # Breeze widget theme for GTK 2 and 3
  ### Icon Theme ###
  "adwaita-icon-theme"  # GNOME standard icons
  
  #//////////////#
  ### | Font | ###
  #//////////////#
  "otf-font-awesome"
  "ttf-firacode-nerd"

  ### FONT EDITOR/SETTINGS ###
  "font-manager"        # A simple font management application for GTK+ Desktop Environments

  #///////////////////////////////////#
  ### | Terminal | Emulator | Shell ###
  #///////////////////////////////////#
  "kitty"           # A modern, hackable, featureful, OpenGL-based terminal emulator
  "alacritty"       # A cross-platform, GPU-accelerated terminal emulator
  "zsh"             # A very advanced and programmable command interpreter (shell) for UNIX
  "fzf"             # Command-line fuzzy finder

  #////////////////////////////////#
  ### |         HYPRLAND       | ###
  #////////////////////////////////#
  # "hyprland"                      # Wayland compositor
  "xdg-desktop-portal"            # Desktop integration portals for sandboxed apps
  "xdg-desktop-portal-hyprland"   # xdg-desktop-portal backend for hyprland
  "qt5-wayland"                   # Provides APIs for Wayland
  "qt6-wayland"                   # Provides APIs for Wayland

  "uwsm"                          # A standalone Wayland session manager

  "nwg-dock-hyprland"         # GTK3-based dock for Hyprland Wayland compositor
  "hyprpaper"                 # a blazing fast wayland wallpaper utility with IPC controls
  "hyprlock"                  # hyprland’s GPU-accelerated screen locking utility
  "hypridle"                  # hyprland’s idle daemon
  "hyprpicker"                # A wlroots-compatible Wayland color picker that does not suck

  #////////////////////////////////#
  ### |      GUI | System      | ###
  #////////////////////////////////#
  "libnotify"       # Library for sending desktop notifications
  "polkit-gnome"    # Legacy polkit authentication agent for GNOME
  "swaync"          # A simple GTK based notification daemon for Sway
  ### monitor ###
  "ddcutil"         # Query and change Linux monitor settings using DDC/CI and USB.
  # "brightnessctl"   # Lightweight brightness control

  #/////////////////#
  ### | Network | ###
  #/////////////////#
  "nm-connection-editor"    # NetworkManager GUI connection editor and widgets
  "networkmanager"          # Network connection manager and user applications
  "network-manager-applet"  # Applet for managing network connections
  "curl"                    # command line tool and library for transferring data with URLs
  "wget"                    # Network utility to retrieve files from the web

  #///////////////////////#
  ### | Audio | Media | ###
  #///////////////////////#
  "pipewire-jack"   # Low-latency audio/video router and processor - JACK replacement
  "pipewire-alsa"   # Low-latency audio/video router and processor - ALSA configuration
  "pipewire-pulse"  # Low-latency audio/video router and processor - PulseAudio replacement
  "wireplumber"     # Session / policy manager implementation for PipeWire
  "pamixer"         # Pulseaudio command-line mixer like amixer
  "pavucontrol"     # PulseAudio Volume Control
  "qjackctl"        # A Qt front-end for the JACK low-latency audio server
  ###      CAMERAS      ###
  # "pipewire-libcamera"      # Low-latency audio/video router and processor - Libcamera support
  # "libcamera"               # A complex camera support library for Linux, Android, and ChromeOS
  # "libcamera-ipa"           # A complex camera support library for Linux, Android, and ChromeOS - signed IPA
  # "libcamera-tools"         # A complex camera support library for Linux, Android, and ChromeOS - tools
  ###      MUSIC & VIDEO      ###
  "mpv"             # a free, open source, and cross-platform media player
  "mpv-mpris"       # MPRIS plugin for mpv
  "mpd"             # Flexible, powerful, server-side application for playing music
  "mpc"             # Minimalist command line interface to MPD
  "ncmpcpp"         # Featureful ncurses based MPD client inspired by ncmpc

  #///////////////////////////#
  ### | Bar | Menu | Lock | ###
  #///////////////////////////#  
  "waybar"                    # Highly customizable Wayland bar for Sway and Wlroots based compositors
  "rofi"                      # A window switcher, application launcher and dmenu replacement

  #////////////////////#
  ### | Screenshot | ###
  #////////////////////#
  "grim"            # Screenshot utility for Wayland
  "slurp"           # Select a region in a Wayland compositor

  #////////////////////#
  ### | Monitoring | ###
  #////////////////////#
  "btop"            # A monitor of system resources, bpytop ported to C++
  "nvtop"           # GPUs process monitoring for AMD, Intel and NVIDIA

  #///////////////////////#
  ### | POWER PROFILE | ###
  #///////////////////////#
 	"power-profiles-daemon"     # Makes power profiles handling available over D-Bus

  #////////////////////////#
  ### | VPN | FIREWALL | ###
  #////////////////////////#
#  "nftables"                #  Netfilter tables userspace tools
#  "proton-vpn-gtk-app"      #  ProtonVPN GTK app, Maintained by Community

  #////////////////////#
  ###   | SENSORS |  ###
  #////////////////////#
  "xsensors"                 # X11 interface to lm_sensors - Mystro256 fork

  #///////////////////#
  ###   | DRIVER |  ###
  #///////////////////#
  "ntfs-3g"         # NTFS filesystem driver and utilities
  ### Bluetooth ###
  # "bluez"         # Daemons for the bluetooth protocol stack
  # "bluez-utils"   # Development and debugging utilities for the bluetooth protocol stack
  # "blueman"       # GTK+ Bluetooth Manager

)
