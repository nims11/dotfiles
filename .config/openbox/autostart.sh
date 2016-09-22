#!/bin/bash
tint2 -c /home/nimesh/.config/tint2/text_only_1.tint2rc &
pnmixer &
~/wallpaper.sh &
compton --config ~/.compton.conf --backend glx --vsync opengl-swc -b &
artha &
AUTOSTART_TMUX=1 terminator &
sudo netctl start eduroam &
