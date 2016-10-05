#!/bin/bash
while true; do
    find ~/wallpapers -maxdepth 1 -type f \( name '*.jpg' -i -name '*.png' \) -print0 | shuf -n1 -z | xargs -0 feh --bg-scale
    sleep 15m
done
