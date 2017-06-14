#!/bin/bash
~/.config/colorscheme.sh apply &
compton -b --config ~/.config/compton.conf
artha &
termite &
~/wallpaper.sh &
# ~/.config/start-internet.sh &
/usr/lib/notification-daemon-1.0/notification-daemon start &
mpd &
udiskie &
