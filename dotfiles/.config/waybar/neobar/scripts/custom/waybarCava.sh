#!/usr/bin/env bash
# Waybar Audio Visualizer — portable, debug-friendly
set -u
IFS=$'\n'

# === konfigurasi ===
bar_chars=(▁ ▂ ▃ ▄ ▅ ▆ ▇ █)
decay_rate=1
bars=20
DEBUG=1   # 1 = tampilkan pesan error/debug ke stderr

# buat config sementara
config_file="$(mktemp /tmp/waybar_cava_config.XXXXXX)"

cleanup() {
    [[ -f "$config_file" ]] && rm -f "$config_file"
}
trap cleanup EXIT INT TERM

cat > "$config_file" <<EOF
[general]
bars = $bars

[input]
method = pipewire
source = auto

[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 7
EOF

# cek dependency
if ! command -v cava >/dev/null 2>&1; then
  >&2 echo "ERROR: 'cava' tidak ditemukan. Install dulu (contoh: sudo apt install cava)"
  echo "{\"text\":\"cava not found\",\"class\":\"cava error\"}"
  exit 1
fi

# gradient warna level 0..7
gradient=(
  "#66d9ef" "#7ca6ff" "#a07bff" "#c55dff"
  "#ff66cc" "#ff6699" "#ff9966" "#ffcc66"
)

# inisialisasi last_values
declare -a last_values
for ((i=0;i<bars;i++)); do last_values[i]=0; done

# jalankan cava langsung dan baca outputnya (lebih portable)
# buka cava sebagai subprocess dan baca via process substitution
while IFS= read -r line || [[ -n "$line" ]]; do
    # debug raw line
    $DEBUG && >&2 echo "RAW: $line"

    line="${line//;/}"   # hapus semicolon jika ada
    out=""
    total=0

    for ((i=0;i<bars;i++)); do
        n_char="${line:i:1}"
        if [[ "$n_char" =~ [0-7] ]]; then
            n=$n_char
        else
            n=0
        fi
        (( total += n ))

        # smoothing / decay
        if (( n >= last_values[i] )); then
            last_values[i]=$n
        else
            new=$(( last_values[i] - decay_rate ))
            (( new < 0 )) && new=0
            last_values[i]=$new
        fi

        level=${last_values[i]}
        (( level < 0 )) && level=0
        (( level > 7 )) && level=7
        color="${gradient[level]}"

        # buat span (gunakan single quotes di attribute agar aman)
        out+="<span foreground='${color}'>${bar_chars[level]}</span>"
    done

    avg=0
    if (( bars > 0 )); then avg=$(( total / bars )); fi

    # cetak JSON (Waybar expects one-line JSON)
    printf '%s\n' "{\"text\":\"$out\", \"class\":\"cava level$avg\"}"

done < <(cava -p "$config_file" 2>&1)
