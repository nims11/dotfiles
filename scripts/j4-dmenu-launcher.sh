#!/bin/sh
BG=$(xrdb -query | egrep '^\*.background\s*:\s*' | tr ':' ' ' | awk '{print $2}' | tail -1)
FG=$(xrdb -query | egrep '^\*.foreground\s*:\s*' | tr ':' ' ' | awk '{print $2}' | tail -1)
HEIGHT=$(xrdb -query | egrep '^lbar.height\s*:\s*' ~/.Xresources | tr ':' ' ' | awk '{print $2}' | tail -1)
FONTSIZE=$(xrdb -query | egrep '^lbar.fontsize\s*:\s*' ~/.Xresources | tr ':' ' ' | awk '{print $2}' | tail -1)
echo $HEIGHT
echo $FONTSIZE
j4-dmenu-desktop \
    --dmenu="(cat; echo suspend$'\n'reboot$'\n'poweroff) |\
    "'dmenu -b -q -i -h "'$HEIGHT'" -p ">" -fn "Ubuntu Mono-"'$FONTSIZE'""\
    -nb "'$BG'" -nf "'$FG'" -sb "'$FG'" -sf "'$BG'"'\
    --term="termite"
