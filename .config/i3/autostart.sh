#!/bin/bash
~/.config/colorscheme.sh apply &
(~/wallpaper.sh; i3lock -i /tmp/cur_wallpaper.png) &
compton -b --config ~/.config/compton.conf
artha &
termite &
~/.config/start-internet.sh &
/usr/lib/notification-daemon-1.0/notification-daemon start &
mpd &
udiskie &
