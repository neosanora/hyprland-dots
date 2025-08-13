#!/usr/bin/env bash

# ============================================
# 🎯 Daftar Package
# ============================================

packages=(
  #////////////////////#
  ### | Tools Umum | ###
  #////////////////////#
  "firefox"         # Browser
  "git"             # version control
  "jq"              # JSON processor
  "gum"             # command line UI toolkit
  "fastfetch"       # system information tool

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
  "qt6ct"           # Qt 6 Configuration Utility
  "nwg-look"        # GTK settings editor adapted to work on wlroots-based compositors

# widget theme
  "breeze-gtk"      # Breeze widget theme for GTK 2 and 3

  
  #//////////////#
  ### | Font | ###
  #//////////////#
  
  "ttf-font-awesome"
  "ttf-fira-sans"
  "ttf-fira-code"
  "ttf-firacode-nerd"

  "noto-fonts-cjk"
  
# FONT EDITOR/SETTINGS
  "font-manager"        #A simple font management application for GTK+ Desktop Environments

  #////////////////////////////////#
  ### | Display | Manager | WM | ###
  #////////////////////////////////#
  "hyprland"                      # Wayland compositor
  "xdg-desktop-portal-hyprland"   # xdg portal untuk Hyprland
  "qt5-wayland"                   # Qt support for Wayland
  "qt6-wayland"                   # Qt support for Wayland

  #///////////////////////////////////#
  ### | Terminal | Emulator | Shell ###
  #///////////////////////////////////#
  "kitty"           # Terminal modern dan cepat
  "alacritty"       # Terminal GPU-accelerated

  #////////////////////////////////#
  ### | Aplikasi | GUI | System |###
  #////////////////////////////////#
  "libnotify"       # Library for sending desktop notifications
  "polkit-gnome"    # Legacy polkit authentication agent for GNOME
  "swaync"          # A simple GTK based notification daemon for Sway
  
  "ddcutil"         # Query and change Linux monitor settings using DDC/CI and USB.
  
  # "brightnessctl"   # Lightweight brightness control tool ---(laptop)---

  #/////////////////#
  ### | Network | ###
  #/////////////////#
  "networkmanager"  # Manajemen jaringan (WiFi/Ethernet)
  "curl"            # command line tool and library for transferring data with URLs
  "wget"            # Network utility to retrieve files from the web

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

  #///////////////////////////#
  ### | Bar | Menu | Lock | ###
  #///////////////////////////#

  "nwg-dock-hyprland"         # GTK3-based dock for Hyprland Wayland compositor
  
  "waybar"                    # Widget bar / status bar
  "rofi-wayland"              # Wayland app launcher
  "hyprpaper"                 # Wallpaper manager
  "wlogout"                   # GUI logout menu
  "hyprlock"                  # Lock screen Hyprland

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


  #////////////////////////#
  ### | VPN | FIREWALL | ###
  #////////////////////////#
  "nftables"                #Netfilter tables userspace tools
  "proton-vpn-gtk-app"      #ProtonVPN GTK app, Maintained by Community


  #///////////////////#
  ###   | DRIVER |  ###
  #///////////////////#
  "ntfs-3g"         #NTFS filesystem driver and utilities

# Bluetooth
  "bluez"
  "bluez-utils"
  "blueman"

)
