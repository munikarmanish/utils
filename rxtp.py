#!/usr/bin/env python3

import sys
import time
from pathlib import Path


def parse_arguments():
    if len(sys.argv) < 2:
        print("Usage: rxtp.py device [delay]", file=sys.stderr)
        sys.exit(1)

    netdev = sys.argv[1]

    try:
        delay = int(sys.argv[2])
    except IndexError:
        delay = 1

    return netdev, delay


def print_stats(netdev, delay):
    rx_packets = Path(f"/sys/class/net/{netdev}/statistics/rx_packets")
    rx_dropped = Path(f"/sys/class/net/{netdev}/statistics/rx_dropped")
    rx_bytes = Path(f"/sys/class/net/{netdev}/statistics/rx_bytes")

    rx1 = int(rx_packets.read_text())
    drop1 = int(rx_dropped.read_text())
    bytes1 = int(rx_bytes.read_text())

    time.sleep(delay)

    rx2 = int(rx_packets.read_text())
    drop2 = int(rx_dropped.read_text())
    bytes2 = int(rx_bytes.read_text())

    pkt_rate = (rx2 - rx1) // delay
    drop_rate = (drop2 - drop1) // delay
    byte_rate = (bytes2 - bytes1) * 8 / delay / 1024**3
    print(f"{pkt_rate:11,} pkts, {byte_rate:5.2f} Gbps, {drop_rate:10,} drops")


if __name__ == "__main__":
    netdev, delay = parse_arguments()
    while True:
        print_stats(netdev, delay)
