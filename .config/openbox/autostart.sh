#!/bin/bash
(~/wallpaper.sh; i3lock -i /tmp/cur_wallpaper.png) &
compton &
artha &
termite &
sudo netctl start eduroam &
python2 ~/.config/panel/lbar.py &
