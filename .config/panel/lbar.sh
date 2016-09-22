#!/bin/bash
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

while [[ 1 ]]; do 
    draw_bar
    sleep 0.5
done | lemonbar -b -g x30 -B#333 -f "FontAwesome-10" -f "Inconsolata-10"
