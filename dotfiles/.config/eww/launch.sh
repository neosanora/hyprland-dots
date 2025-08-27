#!/usr/bin/env bash
bash -c 'eww open bar_widget && eww update get_vol="$(pamixer --get-volume)" && ~/.config/eww/scripts/getvol.sh'