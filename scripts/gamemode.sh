#!/bin/bash
if [ -f /tmp/gamemode ]; then
    echo "Disabling game mode"
    notify-send "Disabling game mode"
    rm /tmp/gamemode
    compton -b --config ~/.config/compton.conf
    sudo cpupower frequency-set -g powersave
else
    echo "Enabling game mode"
    notify-send "Enabling game mode"
    touch /tmp/gamemode
    killall compton
    sudo cpupower frequency-set -g performance
fi
