#!/bin/sh
source ~/.config/colorscheme.config
j4-dmenu-desktop \
    --dmenu='dmenu -b -q -i -h 25 -p ">" -fn "Ubuntu Mono-9" -nb "#'$BG'" -nf "#'$FG'" -sb "#'$FG'" -sf "#'$BG'"'\
    --term="termite"
