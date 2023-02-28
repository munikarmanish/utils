#!/usr/bin/env python3

import sys
import time
from pathlib import Path


def parse_arguments():
    if len(sys.argv) < 2:
        print("Usage: rxtp.py device [delay] [fragments]", file=sys.stderr)
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

    rx_packets = Path(f"/sys/class/net/{netdev}/statistics/rx_packets")
    rx_dropped = Path(f"/sys/class/net/{netdev}/statistics/rx_dropped")

    rx1 = int(rx_packets.read_text())
    drop1 = int(rx_dropped.read_text())

    time.sleep(delay)

    rx2 = int(rx_packets.read_text())
    drop2 = int(rx_dropped.read_text())

    pkt_rate = (rx2 - rx1) // delay
    print(f"pkt_rate: {pkt_rate:,}")

    if frags > 1:
        msg_rate = pkt_rate // frags
        print(f"msg_rate: {msg_rate:,}")

    drop_rate = (drop2 - drop1) // delay
    print(f"drop_rate: {drop_rate:,}")


if __name__ == "__main__":
    main()
