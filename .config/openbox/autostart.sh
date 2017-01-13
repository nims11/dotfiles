#!/bin/bash
~/.config/colorscheme.sh apply &
(~/wallpaper.sh; i3lock -i /tmp/cur_wallpaper.png) &
compton &
artha &
termite &
~/.config/start-internet.sh &
/usr/lib/notification-daemon-1.0/notification-daemon start &
mpd &
udiskie &
