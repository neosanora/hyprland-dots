#!/usr/bin/env bash

# Deteksi GPU otomatis
if command -v nvidia-smi &>/dev/null; then
    # NVIDIA
    usage=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits | head -n 1)
    echo "${usage}%"
elif command -v rocm-smi &>/dev/null; then
    # AMD ROCm
    usage=$(rocm-smi --showuse | grep -m 1 "%" | awk '{print $2}')
    echo "${usage}%"
elif command -v intel_gpu_top &>/dev/null; then
    # Intel (butuh sudo / setuid intel_gpu_top)
    usage=$(timeout 0.2 intel_gpu_top -J | jq '.engines.render.busy' | head -n 1)
    echo "${usage}%"
else
    echo "N/A"
fi
