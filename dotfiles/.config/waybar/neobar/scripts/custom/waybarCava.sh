#!/usr/bin/env bash
# Waybar Audio Visualizer (PipeWire + Smooth Fading)
# by neonora & ChatGPT 2025

bar_chars=(▁ ▂ ▃ ▄ ▅ ▆ ▇ █)
config_file="/tmp/waybar_cava_config"
decay_rate=1   # seberapa cepat bar turun (0=instan, 1=halus, 2=lebih halus)

# Buat config sementara untuk cava
cat > "$config_file" <<EOF
[general]
bars = 20

[input]
method = pipewire
source = auto

[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 7
EOF

# Matikan cava lama
pkill -f "cava -p $config_file" 2>/dev/null

# Fungsi gradient warna
get_color() {
    case $1 in
        0) echo "#55ccff" ;;
        1) echo "#66aaff" ;;
        2) echo "#8877ff" ;;
        3) echo "#aa55ff" ;;
        4) echo "#cc44ff" ;;
        5) echo "#ff44cc" ;;
        6) echo "#ff4488" ;;
        7) echo "#ff4444" ;;
        *) echo "#999999" ;;
    esac
}

# Array untuk menyimpan nilai bar terakhir
declare -a last_values
for ((i=0; i<20; i++)); do last_values[i]=0; done

# Jalankan cava
cava -p "$config_file" | while read -r line; do
    line="${line//;/}"
    out=""

    for ((i=0; i<${#line}; i++)); do
        n="${line:i:1}"
        [[ "$n" =~ [0-7] ]] || continue

        # Smooth decay logic
        if (( n >= last_values[i] )); then
            last_values[i]=$n
        else
            new=$(( last_values[i] - decay_rate ))
            (( new < n )) && new=$n
            (( new < 0 )) && new=0
            last_values[i]=$new
        fi

        color=$(get_color "${last_values[i]}")
        out+="<span color='$color'>${bar_chars[${last_values[i]}]}</span>"
    done

    echo "{\"text\":\"$out\", \"class\":\"cava\"}"
done
