#!/usr/bin/env bash

# 🎨 warna pelangi (bisa kamu ubah sesuai selera)
colors="0xffe74c3c 0xfff39c12 0xfff1c40f 0xff2ecc71 0xff3498db 0xff9b59b6"

deg=0
while true; do
    hyprctl keyword general:col.active_border $colors ${deg}deg
    deg=$(( (deg + 5) % 360 ))   # muter keliling 360 derajat
    sleep 0.1                    # makin kecil makin cepat animasi
done

# for rainbow borders animation

# function random_hex() {
#     random_hex=("0xff$(openssl rand -hex 3)")
#     echo $random_hex
# }

# rainbow colors only for active window
# hyprctl keyword general:col.active_border $(random_hex)  $(random_hex) $(random_hex) $(random_hex) $(random_hex) $(random_hex) $(random_hex) $(random_hex) $(random_hex) $(random_hex)  270deg

# rainbow colors for inactive window (uncomment to take effect)
#hyprctl keyword general:col.inactive_border $(random_hex) $(random_hex) $(random_hex) $(random_hex) $(random_hex) $(random_hex) $(random_hex) $(random_hex) $(random_hex) $(random_hex) 270deg