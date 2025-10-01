#!/usr/bin/env bash

# ============================================
# 🎯 Daftar Package
# ============================================

packages=(
  #////////////////////#
  ### |    Tools   | ###
  #////////////////////#
  "imagemagick"     # Software suite to create, edit, compose, or convert bitmap images
  "tumbler"         # Thumbnail service implementing the thumbnail management D-Bus specification
  "gvfs"            # Virtual filesystem implementation for GIO
  "inotify-tools"   # inotify-tools is a C library and a set of command-line programs for Linux providing a simple interface to inotify.
  ###  can be execute ###
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
  "vim"             # text editor
  "neovim"          # modern text editor

  #//////////////////////#
  ### | File Manager | ###
  #//////////////////////#
  "ranger"          # File Manager Like NVIM
  "thunar"          # File manager ringan (XFCE)

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
  "font-manager"        #A simple font management application for GTK+ Desktop Environments

  #////////////////////////////////#
  ### |         HYPRLAND       | ###
  #////////////////////////////////#
  # "hyprland"                      # Wayland compositor
  "xdg-desktop-portal-hyprland"   # xdg portal untuk Hyprland
  "qt5-wayland"                   # Qt support for Wayland
  "qt6-wayland"                   # Qt support for Wayland

  "uwsm"                          # A standalone Wayland session manager

  "nwg-dock-hyprland"         # GTK3-based dock for Hyprland Wayland compositor
  "hyprpaper"                 # Wallpaper manager
  "hyprlock"                  # Lock screen Hyprland
  "hypridle"                  # hyprland’s idle daemon
  "hyprpicker"                # A wlroots-compatible Wayland color picker that does not suck

  #///////////////////////////////////#
  ### | Terminal | Emulator | Shell ###
  #///////////////////////////////////#
  "kitty"           # Terminal modern dan cepat
  "alacritty"       # Terminal GPU-accelerated
  "zsh"             # A very advanced and programmable command interpreter (shell) for UNIX
  "fzf"             # Command-line fuzzy finder

  #////////////////////////////////#
  ### |      GUI | System      | ###
  #////////////////////////////////#
  "libnotify"       # Library for sending desktop notifications
  "polkit-gnome"    # Legacy polkit authentication agent for GNOME
  "swaync"          # A simple GTK based notification daemon for Sway
  ### monitor ###
  "ddcutil"         # Query and change Linux monitor settings using DDC/CI and USB.
  # "brightnessctl"   # Lightweight brightness control tool ---(laptop)---

  #/////////////////#
  ### | Network | ###
  #/////////////////#
  "nm-connection-editor"    # NetworkManager GUI connection editor and widgets
  "networkmanager"          # Manajemen jaringan (WiFi/Ethernet)
  "network-manager-applet"  # Applet for managing network connections
  "curl"                    # command line tool and library for transferring data with URLs
  "wget"                    # Network utility to retrieve files from the web

  #///////////////////////#
  ### | Audio | Media | ###
  #///////////////////////#
  "pipewire-jack"   # JACK support via PipeWire
  "pipewire-alsa"   # ALSA support via PipeWire
  "pipewire-pulse"  # PulseAudio replacement via PipeWire
  "wireplumber"     # Session manager PipeWire
  "pamixer"         # CLI audio mixer
  "pavucontrol"     # PulseAudio Volume Control
  "qjackctl"        # A Qt front-end for the JACK low-latency audio server
  ###      ADDITIONAL      ###
  "mpv"
  "mpv-mpris"

  #///////////////////////////#
  ### | Bar | Menu | Lock | ###
  #///////////////////////////#  
  "waybar"                    # Widget bar / status bar
  "rofi"                      # Wayland app launcher

  #////////////////////#
  ### | Screenshot | ###
  #////////////////////#
  "grim"            # Alat screenshot untuk Wayland
  "slurp"           # Area selector (buat grim)

  #////////////////////#
  ### | Monitoring | ###
  #////////////////////#
  "btop"
  "nvtop"           # Monitor GPU usage (mirip htop)

  #///////////////////////#
  ### | POWER PROFILE | ###
  #///////////////////////#
 	"power-profiles-daemon"     # Makes power profiles handling available over D-Bus

  #////////////////////////#
  ### | VPN | FIREWALL | ###
  #////////////////////////#
#  "nftables"                #Netfilter tables userspace tools
#  "proton-vpn-gtk-app"      #ProtonVPN GTK app, Maintained by Community


  #///////////////////#
  ###   | DRIVER |  ###
  #///////////////////#
  "ntfs-3g"         #NTFS filesystem driver and utilities
  ### Bluetooth ###
  "bluez"
  "bluez-utils"
  "blueman"

)
