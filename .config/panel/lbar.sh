#!/bin/bash
BRIGHT_FILE=/sys/class/backlight/acpi_video0

mktempfifo(){
    tmppipe=$(mktemp -u)
    mkfifo -m 600 "$tmppipe"
    echo "$tmppipe"
}

BAR_PIPE=$(mktempfifo)
FEEDBACK_PIPE=$(mktempfifo)
UPDATES_PIPE=$(mktempfifo)

# HANDLERS
# These methods are responsible to handle actions from lemonbar
volhandler(){
    if [[ $# == 1 ]]; then
        /usr/bin/pavucontrol >/dev/null &
    else
        case $2 in
            up) amixer -D pulse sset Master 3%+ >/dev/null
                ;;
            down) amixer -D pulse sset Master 3%- >/dev/null
                ;;
            *) return
                ;;
        esac
        echo "redraw"
    fi
}

brightness_handler(){
    BRIGHTNESS_LEVEL=$(cat "$BRIGHT_FILE/brightness")
    case $2 in
        up) sudo tee "$BRIGHT_FILE/brightness" <<< $((BRIGHTNESS_LEVEL+1))  >/dev/null
            ;;
        down) sudo tee "$BRIGHT_FILE/brightness" <<< $((BRIGHTNESS_LEVEL-1))  >/dev/null
            ;;
        *) return
            ;;
    esac
    echo "redraw"
}

handler(){
    case $1 in 
        calendar)
            /usr/bin/gsimplecal >/dev/null &
            ;;
        volume)
            volhandler "$@" &
            ;;
        brightness)
            brightness_handler "$@" &
            ;;
    esac
}

# VIEWS
wname(){
    xdotool getactivewindow getwindowname
}

clock(){
    echo "%{A:calendar:}$(date '+%b %d %I:%M')%{A}"
}

volume(){
    VOL_LEVEL_=$(amixer get Master | awk -F"[][]" '/[.*?%]/{print $2}' | head -1)
    VOL_LEVEL_=${VOL_LEVEL_%%%}
    IFS=
    read VOL_LEVEL < <(printf "%3s" $VOL_LEVEL_)
    echo -e "%{A4:volume up:}%{A5:volume down:}%{A:volume:}\uF028 ${VOL_LEVEL}%{A}%{A}%{A}"
}

MAX_BRIGHTNESS=$(cat "$BRIGHT_FILE/max_brightness")
BRIGHTNESS_PAD=${#MAX_BRIGHTNESS}
brightness(){
    IFS=
    read BRIGHTNESS_LEVEL < <(printf "%${BRIGHTNESS_PAD}s" $(cat "$BRIGHT_FILE/brightness"))
    echo -e "%{A4:brightness up:}%{A5:brightness down:}\uF0EB ${BRIGHTNESS_LEVEL}%{A}%{A}"
}

updates(){
    NUM=$1
    if [[ "$NUM" > 0 ]]; then
        echo "$NUM  "
    fi
}

# lemonbar event loop
UPDATES=0
while read line; do
    echo $line >> /tmp/lbar.log
    case $line in
        redraw)
            echo "%{l} $(wname)%{r} $(updates)$(brightness)  $(volume)  $(clock) "
            ;;
        "updates *")
            UPDATES=$(cat updates | sed 's/updates //')
            ;;
    esac
done < $BAR_PIPE | lemonbar -b -g x20 -B#333 -f "Inconsolata-8" -f "FontAwesome-8"  > $FEEDBACK_PIPE &

# action event loop
while read line; do
    echo $line >> /tmp/lbar.log
    handler $line
done < $FEEDBACK_PIPE > $BAR_PIPE &

# periodic redrawing
while true; do
    echo redraw
    sleep 1
done > $BAR_PIPE
