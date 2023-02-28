#!/bin/bash

if (($# != 2)); then
    >&2 echo "Usage: generate-flamegraph.sh <core> <duration>"
    exit 1
fi

cpu=$1
duration=$2

sudo perf record -C $cpu -F max -g -- sleep $duration
sudo perf script | stackcollapse-perf > out.folded
flamegraph out.folded > out.svg
