#!/usr/bin/env bash
# pactl is required
# passing arg

check=$(pactl list short | grep -E "RUNNING.*alsa_output|alsa_output.*RUNNING")
check_mic=$(pactl list short | grep -E "RUNNING.*alsa_input|alsa_input.*RUNNING")

speaker_check() {
    if [ -z "$check" ]; then
        echo ""
    else
        echo "󪤁"
    fi
}

mic_check() {
    if [ -z "$check_mic" ]; then
        echo ""
    else
        echo "󪥀"
    fi
}

cam_check() {
    if [ -e /dev/video0 ]; then
        check_webcam=$(lsof /dev/video0 2>/dev/null | grep mem)
        if [ -n "$check_webcam" ]; then
            echo "󪤧"
        else
            echo ""
        fi
    else
        echo ""
    fi
}

if [ "$1" == "S" ]; then
    speaker_check
elif [ "$1" == "M" ]; then
    mic_check
elif [ "$1" == "C" ]; then
    cam_check
else
    exit
fi
