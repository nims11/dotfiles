#!/bin/bash
if [[ $# < 1 || $# > 5 ]]; then
    echo "usage: ./colorscheme.sh scheme_name"
    echo "usage: ./colorscheme.sh bg fg"
    echo "usage: ./colorscheme.sh bg fg opacity"
    echo "usage: ./colorscheme.sh bg fg alt_bg alt_fg"
    echo "usage: ./colorscheme.sh bg fg alt_bg alt_fg opacity"
    exit 1
fi

OPACITY=EE
BG=141311
FG=686766
ALTBG=686766
ALTFG=141311
WEATHER=waterloo

if [[ $# == 1 ]]; then
    if [[ $1 == "default" ]]; then
        echo "Profile default..."
    elif [[ $1 == "random" ]]; then
        BG=$(python -c\
            'import random; \
            r = lambda: random.randint(0, 255); \
            print("%02X%02X%02X" % (r(), r(), r()))')
        FG=$(python -c\
            'import random; \
            r = lambda: random.randint(0, 255); \
            print("%02X%02X%02X" % (r(), r(), r()))')
        ALTBG=$FG
        ALTFG=$BG
    fi
else
    BG="$1"
    FG="$2"
    ALTBG="$FG"
    ALTFG="$BG"
    if [[ $# == 3 ]]; then
        OPACITY="$3"
    fi
    if [[ $# > 3 ]]; then
        ALTBG="$3"
        ALTFG="$4"
        if [[ $# == 5 ]]; then
            OPACITY="$5"
        fi
    fi
fi

(echo "OPACITY=\"$OPACITY\""
echo "BG=\"$BG\""
echo "FG=\"$FG\""
echo "ALTBG=\"$ALTBG\""
echo "ALTFG=\"$ALTFG\""
echo "WEATHER=\"$WEATHER\"") > ~/.config/colorscheme.config

kill $(ps ax | grep python2 | grep lbar.py | awk '{print $1}')
python2 ~/.config/panel/lbar.py &>/dev/null &
disown
