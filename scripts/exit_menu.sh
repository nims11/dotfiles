#!/bin/sh
BG=$(xrdb -query | egrep '^\*.background\s*:\s*' | tr ':' ' ' | awk '{print $2}' | tail -1)
FG=$(xrdb -query | egrep '^\*.foreground\s*:\s*' | tr ':' ' ' | awk '{print $2}' | tail -1)
HEIGHT=$(xrdb -query | egrep '^lbar.height\s*:\s*' ~/.Xresources | tr ':' ' ' | awk '{print $2}' | tail -1)
FONTSIZE=$(xrdb -query | egrep '^lbar.fontsize\s*:\s*' ~/.Xresources | tr ':' ' ' | awk '{print $2}' | tail -1)
RESP=$(echo -e 'exit\nreboot\npoweroff\nsuspend' | dmenu -b -i -h $HEIGHT -p ">" -fn "Ubuntu Mono - $FONTSIZE" \
    -nb $BG -nf $FG -sb $FG -sf $BG)

case "$RESP" in 
    "exit")
        i3-msg exit
        ;;
    "poweroff")
        poweroff
        ;;
    "reboot")
        reboot
        ;;
    "suspend")
        systemctl suspend
        ;;
esac
