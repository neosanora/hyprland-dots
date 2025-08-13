#!/usr/bin/env bash


# Gunakan nvtop JSON backend jika tersedia
if command -v nvtop &>/dev/null; then
    # Coba pakai nvidia-smi (karena nvtop tidak bisa dump info via CLI)
    if command -v nvidia-smi &>/dev/null; then
        usage=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits | head -n 1)
        echo "${usage}%"
        exit
    fi

    # Coba pakai radeontop untuk AMD (fallback)
    if command -v radeontop &>/dev/null; then
        usage=$(radeontop -l 1 -d - | grep -m 1 "gpu" | awk -F '[:,%]' '{print $2}' | tr -d ' ')
        echo "${usage:-0}%"
        exit
    fi
fi

# Tidak ditemukan alat yang sesuai
echo "N/A"