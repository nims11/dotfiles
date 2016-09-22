#!/bin/sh
DMENU_COMMAND="rofi -dmenu -i -p '>'"
j4-dmenu-desktop  --dmenu="$DMENU_COMMAND" --term="IN_TMUX=1 terminator"
