#!/bin/bash

print_help() {
    echo "Usage: delete_container.sh <id>" >&2
    exit 1
}

# handle command line options
while getopts ":h" option; do
    case $option in
        h) print_help;;
        *) print_help;;
    esac
done

(( $# != 1 )) && print_help

id=$1

ns="ns$id"
ip="1.0.0.$id/24"
veth="veth0"
vethp="veth$id"

sudo ip link delete $vethp
sudo ip netns delete $ns
