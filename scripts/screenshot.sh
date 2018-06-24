#!/bin/bash
mkdir -p ~/Pictures/Screenshots
cd ~/Pictures/Screenshots
if [[ $1 == "select" ]]; then
    scrot -s
elif [[ $1 == "window" ]]; then
    scrot -u
else
    scrot
fi

notify-send "Saving screenshot" -t 500
