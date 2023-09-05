#!/bin/bash

print_help() {
    echo "Usage: create_vxlan_net.sh <vni>" >&2
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

nic="enp129s0f0np0"
vx="vxlan${vni}"
br="br${vni}"
group="239.1.1.1"
vxport="4789"

sudo ip link add $vx type vxlan id $vni group $group dstport $vxport dev $nic
sudo ip link add $br type bridge
sudo ip link set $vx master $br
sudo ip link set $vx up
sudo ip link set $br up

