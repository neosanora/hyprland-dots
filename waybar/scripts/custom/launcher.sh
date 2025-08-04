#!/usr/bin/env bash
# pactl is required
#

count=$(swaync-client --list | grep -c '"id"')
echo "$count"
