#!/bin/sh
BG=$(egrep '^\*.background\s*:\s*' ~/.Xresources | tr ':' ' ' | awk '{print $2}' | tail -1)
FG=$(egrep '^\*.foreground\s*:\s*' ~/.Xresources | tr ':' ' ' | awk '{print $2}' | tail -1)
j4-dmenu-desktop \
    --dmenu="(cat; echo suspend$'\n'reboot$'\n'poweroff) |\
    "'dmenu -b -q -i -h 25 -p ">" -fn "Ubuntu Mono-9"\
    -nb "'$BG'" -nf "'$FG'" -sb "'$FG'" -sf "'$BG'"'\
    --term="termite"
