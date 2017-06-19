#!/bin/bash
if  killall redshift; then
    :
else
    redshift -l 43.464258:-80.52041 &
    disown
fi
