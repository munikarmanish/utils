#!/bin/bash

# make sure there are 2 args
if (( $# != 2 )); then
    >&2 echo "Usage: cache-stat.sh <core> <duration>"
fi

cpu=$1
interval=$2
events=$(paste -sd, $HOME/cache-events.txt)

#echo "Counting events: $events"
sudo perf stat -C $cpu -e $events -- sleep $interval 2>&1
