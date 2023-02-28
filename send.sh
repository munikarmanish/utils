#!/bin/bash
#
#	$1  = starting port number
#	$2  = number of servers
#	$3  = number of clients per server
#	$4+ = sockperf arguments
#
#	Eg: ./send.sh 12345 1 3 ul -i 10.0.1.2 --mps=max -t 10

print_usage() {
	echo "$0 <start_core> <n_cores> <start_port> <n_servers> <n_clients> <sockperf_args>..." >&2
}

if (( $# < 6 )); then
    print_usage
    exit 1
fi

start_core=$1; shift; ncores=$1

shift

starting_port=$1
if (( $starting_port < 1024 )); then
	print_usage
	exit 1
fi

shift

num_servers=$1
if (( $num_servers < 1 )); then
	print_usage
	exit 1
fi

shift

num_clients=$1
if (( $num_clients < 1 )); then
	print_usage
	exit 1
fi

shift

sockperf_args=$@
core=0
for i in $(seq 1 $num_servers); do
    port=$(( $starting_port + $i - 1 ))
    for j in $(seq 1 $num_clients); do
        c=$(( start_core + ( core * 2 ) ))
        echo "Testing server port $port"
        if (( $i == $num_servers && $j == $num_clients )); then
            taskset -c $c sockperf $sockperf_args -p $port > __out$i.$j
        else
            taskset -c $c sockperf $sockperf_args -p $port > __out$i.$j &
        fi
        core=$(( ( core + 1 ) % ncores ))
    done
done

egrep --color 'Summary:' -B2 -A11 __out*

rm __out*
