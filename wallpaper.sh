#!/bin/bash
path=$(find ~/wallpapers -maxdepth 1 -type f \( -name '*.jpg' -o -name '*.png' \) | shuf -n1)
resolution=$(xdpyinfo | grep 'dimensions:' | awk '{print $2}')
convert "$path" -resize $resolution! /tmp/cur_wallpaper.png
feh --bg-scale /tmp/cur_wallpaper.png
