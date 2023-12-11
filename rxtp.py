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
    print(f"{pkt_rate:11,} pkts, {drop_rate:10,} drops, {byte_rate:5.2f} Gbps")

    # if frags > 1:
    #     msg_rate = pkt_rate // frags
    #     print(f"msg_rate: {msg_rate:,}")


if __name__ == "__main__":
    main()
