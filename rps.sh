#!/bin/bash

nproc=$(nproc)
num_queues=${1:-$nproc}
nic=$(ip l | grep -Po "enp94.+(?=:)")
qlen=2048

echo "Setting NIC queue length to $qlen"
sudo ethtool -G $nic rx $qlen tx $qlen

echo "Setting number of NIC queues to $num_queues"
sudo ethtool -L $nic combined $num_queues

echo "Fixing RSS queue-to-cpu map"
keyword="mlx5_comp"
if [[ $nic == "eno1" ]]; then
    keyword="eno1-TxRx-"
fi
for i in $(seq 0 $((nproc - 1))); do
    irq=$(cat /proc/interrupts | grep -E "${keyword}${i}(@.+)?$" | awk '{ print $1 }' | cut -d: -f1)
    irqnames[$i]="${keyword}${i}"
    irqs[$i]=$irq
done
i=0
for irq in ${irqs[@]}; do
    map_decimal=$((2**i))
    map=$(printf "%x" $map_decimal)
    if (( ${#map} > 8 )); then
        map=$(sed -re 's/(.+)(........)/\1,\2/' <<< $map)
    fi

    sudo sh -c "echo $map > /proc/irq/$irq/smp_affinity"
    cpu=$(printf "%.0f" $(echo "l($map_decimal)/l(2)" | bc -l))
    echo "    irq-$irq (${irqnames[$i]}) -> $map (cpu $cpu)"
    i=$(( (i+1) % nproc ))
    if (( $i >= $num_queues )); then break; fi
done

# echo "Adding flow-steering rule"
# sudo ethtool -K $nic ntuple on
# sudo ethtool -N $nic rx-flow-hash udp4 sd
# sudo ethtool -N $nic delete 1023
# sudo ethtool -N $nic delete 1024
# sudo ethtool -N $nic flow-type ip4 src-ip $remote_ip action 0 loc 1023

echo "Setting RPS cpu maps"
N=$(find /sys/class/net/$nic/queues -iname rps_cpus | wc -l)
for i in $(seq 0 $(($num_queues-1))); do
    f=/sys/class/net/$nic/queues/rx-$i/rps_cpus
    if (( i % 2 == 0 )); then
        map="55,55555555"
    else
        map="aa,aaaaaaaa"
    fi
    # map=00,00000555 # RPS on first 5 cores
    # map=55,40000000 # RPS on last 5 cores
    map=0
    if (( $num_queues == 1 )); then
        map=0
    fi
    sudo sh -c "echo $map > $f"
    echo "    $f -> $map"
done
