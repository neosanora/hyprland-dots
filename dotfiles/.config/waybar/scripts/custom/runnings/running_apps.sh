#!/usr/bin/env bash

apps=$(hyprctl clients -j | jq -r '.[].class' | sort -u)

if [ -z "$apps" ]; then
    echo ""
    echo ""
else
    echo ""
    echo "$apps"
fi
