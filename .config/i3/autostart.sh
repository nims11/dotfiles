#!/bin/bash
~/.config/colorscheme.sh apply &
compton -b --config ~/.config/compton.conf
~/wallpaper.sh &
/usr/lib/notification-daemon-1.0/notification-daemon start &
mpd &
udiskie &
blueman-applet &
autorandr-launcher &
xset -b
