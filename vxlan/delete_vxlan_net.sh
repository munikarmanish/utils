#!/bin/bash

print_help() {
    echo "Usage: delete_vxlan_net.sh <vni>" >&2
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

vni=$1

vx="vxlan${vni}"
br="br${vni}"

sudo ip link delete $vx
sudo ip link delete $br
