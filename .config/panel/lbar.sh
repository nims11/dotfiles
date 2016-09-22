#!/bin/bash
mktempfifo(){
    tmppipe=$(mktemp -u)
    mkfifo -m 600 "$tmppipe"
    echo "$tmppipe"
}
BAR_PIPE=$(mktempfifo)
FEEDBACK_PIPE=$(mktempfifo)
volhandler(){
    if [[ $# == 1 ]]; then
        /usr/bin/pavucontrol &
    else
        case $2 in
            up) amixer -D pulse sset Master 3%+ &>/dev/null
                ;;
            down) amixer -D pulse sset Master 3%- &>/dev/null
                ;;
            *) return
                ;;
        esac
        echo "redraw"
    fi
}
handler(){
    case $1 in 
        calendar)
            /usr/bin/gsimplecal &
            ;;
        volume)
            volhandler "$@" &
            ;;
    esac
}

wname(){
    xdotool getactivewindow getwindowname
}

clock(){
    echo "%{A:calendar:}$(date '+%b %d %I:%M')%{A}"
}

volume(){
    VOL_LEVEL=$(amixer get Master | awk -F"[][]" '/[.*?%]/{print $2}')
    echo -e "%{A4:volume up:}%{A5:volume down:}%{A:volume:}\uF028 ${VOL_LEVEL}%{A}%{A}%{A}"
}

draw_bar(){
    echo "%{l} $(wname)%{r} $(volume)   $(clock) "
}


while read line; do
    echo $line >> /tmp/lbar.log
    draw_bar
done < $BAR_PIPE | lemonbar -b -g x30 -B#333 -f "FontAwesome-10" -f "Inconsolata-10" > $FEEDBACK_PIPE &

while read line; do
    echo $line >> /tmp/lbar.log
    handler $line
done < $FEEDBACK_PIPE > $BAR_PIPE &

while true; do
    echo redraw
    sleep 0.5
done > $BAR_PIPE
