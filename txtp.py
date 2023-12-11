#!/usr/bin/env python3

import sys
import time
from pathlib import Path


def parse_arguments():
    if len(sys.argv) < 2:
        print("Usage: txtp.py device [delay] [fragments]", file=sys.stderr)
        sys.exit(1)

    netdev = sys.argv[1]

    try:
        delay = int(sys.argv[2])
    except IndexError:
        delay = 5

    try:
        frags = int(sys.argv[3])
    except IndexError:
        frags = 1

    return netdev, delay, frags


def main():
    netdev, delay, frags = parse_arguments()

    tx_packets = Path(f"/sys/class/net/{netdev}/statistics/tx_packets")
    tx_bytes = Path(f"/sys/class/net/{netdev}/statistics/tx_bytes")

    tx1 = int(tx_packets.read_text())
    bytes1 = int(tx_bytes.read_text())

    time.sleep(delay)

    tx2 = int(tx_packets.read_text())
    bytes2 = int(tx_bytes.read_text())

    pkt_rate = (tx2 - tx1) // delay
    bytes_rate = (bytes2 - bytes1) * 8 / delay / 1024**3
    print(f"{pkt_rate:11,} pkts, {bytes_rate:5.2f} Gbps")


if __name__ == "__main__":
    main()
