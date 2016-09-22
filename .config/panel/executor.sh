#!/bin/bash
vol(){
    if [[ $# == 1 ]]; then
        /usr/bin/pavucontrol &
    else
        case $2 in
            up) amixer -D pulse sset Master 3%+ &>/dev/null
                ;;
            down) amixer -D pulse sset Master 3%- &>/dev/null
                ;;
        esac
    fi
}
handler(){
    case $1 in 
        calendar)
            /usr/bin/gsimplecal &
            ;;
        volume)
            vol "$@" &
            ;;
    esac
}
while read line; do
    echo $line
    handler $line
done
