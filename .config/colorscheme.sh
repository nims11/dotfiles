#!/bin/bash
if [[ $# < 1 || $# > 2 ]]; then
    echo "usage: ./colorscheme.sh [random] [apply]"
    exit 1
fi

if [[ $1 == "random" ]]; then
    shift
fi

function get_xresources() {
    echo $(xrdb -query | egrep '^'$1'\s*:\s*' | tr ':' ' ' | awk '{print $2}' | tail -1)
}

function set_termite_config() {
    cp ~/.config/termite/config.base ~/.config/termite/config
    cat <<EOF >> ~/.config/termite/config
[colors]
background = $(get_xresources '\*.background')
foreground = $(get_xresources '\*.foreground')
EOF

    for i in {0..15}; do
	echo "color$i = $(get_xresources '\*.color'$i)" >> ~/.config/termite/config
    done
}

if [[ $1 == "apply" ]]; then
    BAR_HEIGHT=25
    FONT_SIZE=9
    resolution=$(xdpyinfo | grep 'dimensions:' | awk '{print $2}' | cut -d'x' -f2)
    if [ "$resolution" -gt "900" ]; then
	echo "HIDPI"
    fi
    xrdb -load ~/.Xresources
    echo "lbar.height: $BAR_HEIGHT" | xrdb -merge
    echo "lbar.fontsize: $FONT_SIZE" | xrdb -merge
    xrdb -edit ~/.Xresources

    set_termite_config
    #kill $(ps ax | grep python | grep lbar.py | awk '{print $1}')
    #python ~/.config/panel/lbar.py >/tmp/bar.out 2>/tmp/bar.log &
    #disown
fi
