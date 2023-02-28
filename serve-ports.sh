#!/bin/bash

if (( $# < 4 )); then
    echo "Usage: serve-ports.sh <start-core> <n-cores> <start-port> <n-servers> <sockperf-args>" >&2
    exit 1
fi

startcore=${1:-0}; shift
ncores=${1:-40}; shift
startport=${1:-10000}; shift
nthreads=${1:-40}; shift
args=$@

i=0
while (( i < nthreads )); do
    if (( nthreads == 40 )); then
        core=$(( startcore + ( i  % ncores ) ))
    else
        core=$(( startcore + ( ( i % ncores ) * 2 ) ))
    fi
    port=$(( startport + i ))
    i=$(( i + 1 ))

    echo "Executing on cpu$core: sockperf sr $args -p $port"
    if (( i == nthreads )); then
        taskset -c $core sockperf sr $args -p $port > /dev/null
    else
        taskset -c $core sockperf sr $args -p $port > /dev/null &
    fi
done
