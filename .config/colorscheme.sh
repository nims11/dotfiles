#!/bin/bash
if [[ $# < 1 || $# > 2 ]]; then
    echo "usage: ./colorscheme.sh [random] [apply]"
    exit 1
fi

if [[ $1 == "random" ]]; then
    shift
fi

if [[ $1 == "apply" ]]; then
    xrdb ~/.Xresources
    kill $(ps ax | grep python2 | grep lbar.py | awk '{print $1}')
    python2 ~/.config/panel/lbar.py &>/dev/null &
    disown
fi
