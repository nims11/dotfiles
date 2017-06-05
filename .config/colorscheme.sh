#!/bin/bash
if [[ $# < 1 || $# > 2 ]]; then
    echo "usage: ./colorscheme.sh [random] [apply]"
    exit 1
fi

if [[ $1 == "random" ]]; then
    shift
fi

if [[ $1 == "apply" ]]; then
    BAR_HEIGHT=25
    FONT_SIZE=9
    resolution=$(xdpyinfo | grep 'dimensions:' | awk '{print $2}' | cut -d'x' -f2)
    if [ "$resolution" -gt "900" ]; then
        xrandr --dpi 83x83
        BAR_HEIGHT=35
        FONT_SIZE=12
    fi
    xrdb -load ~/.Xresources
    echo "lbar.height: $BAR_HEIGHT" | xrdb -merge
    echo "lbar.fontsize: $FONT_SIZE" | xrdb -merge
    xrdb -edit ~/.Xresources
    kill $(ps ax | grep python2 | grep lbar.py | awk '{print $1}')
    python2 ~/.config/panel/lbar.py >/tmp/bar.out 2>/tmp/bar.log &
    disown
fi
