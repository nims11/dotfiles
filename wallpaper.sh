#!/bin/bash
if [[ $1 == "next" ]]; then
    cur_wallpaper=$(cat /tmp/cur_wallpaper.path)
    if [ -e "$cur_wallpaper" ]; then
        path=$(find ~/wallpapers -maxdepth 1 -type f \( -name '*.jpg' -o -name '*.png' \)\
            | grep "$cur_wallpaper" -A1 | awk 'NR==2')
    fi
    if [ -z "$path" ]; then
        path=$(find ~/wallpapers -maxdepth 1 -type f \( -name '*.jpg' -o -name '*.png' \) | head -1)
    fi
elif [[ $1 == "select" ]]; then
    path=$(zenity --file-selection --filename=/home/nimesh/wallpapers/) 
else
    path=$(find ~/wallpapers -maxdepth 1 -type f \( -name '*.jpg' -o -name '*.png' \) | shuf -n1)
fi

if [ ! -f "$path" ]; then
    echo "$path" not found
    exit 1
fi
echo "$path" > /tmp/cur_wallpaper.path
resolution=$(xdpyinfo | grep 'dimensions:' | awk '{print $2}')
convert "$path" -resize $resolution! /tmp/cur_wallpaper.png
feh --bg-scale /tmp/cur_wallpaper.png
