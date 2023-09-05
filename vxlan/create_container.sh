#!/bin/bash

print_help() {
    echo "Usage: create_container.sh <id> <vni>" >&2
    exit 1
}

# handle command line options
while getopts ":h" option; do
    case $option in
        h) print_help;;
        *) print_help;;
    esac
done

(( $# != 2 )) && print_help

id=$1
vni=$2

ns="ns$id"
ip="1.0.0.$id/24"
br="br${vni}"
veth="veth$id"
vethp="${veth}p"

# Check if vxlan network has been created. If not, create one.
temp=$(ls /sys/class/net | grep "$br")
(( $? != 0 )) && create_vxlan_net.sh $vni

sudo ip netns add $ns

sudo ip link add $veth mtu 1450 type veth peer name $vethp mtu 1450
sudo ip link set $vethp master $br
sudo ip link set $veth netns $ns
sudo ip -n $ns addr add $ip dev $veth

sudo ip -n $ns link set $veth up
sudo ip -n $ns link set lo up
sudo ip link set $vethp up
