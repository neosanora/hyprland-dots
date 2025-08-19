#!/usr/bin/env bash

choice=$(echo -e "Pavucontrol\nQjackCtl" | rofi -dmenu -p "Audio Tools")

case "$choice" in
    "Pavucontrol") pavucontrol & ;;
    "QjackCtl") qjackctl & ;;
esac
