#!/bin/bash
if  killall redshift; then
    :
else
    redshift &
    disown
fi
