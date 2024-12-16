#!/usr/bin/env python3

import sys
import re

ansi_escape = re.compile(r'\x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])')


def increment_bw_unit(unit: str):
    if unit.lower() == 'k':
        return 'M'
    elif unit.lower() == 'm':
        return 'G'
    else:
        raise ValueError('Invalid unit')


if __name__ == "__main__":
    msg_rate, bandwidth, pkt_rate, msg_size = 0, 0, 0, 1472

    for line in sys.stdin:
        line = ansi_escape.sub('', line)
        # count msg rate
        match = re.search(r'Summary: Message Rate is (\d+) \[msg/sec\]', line)
        if match:
            msg_rate += int(match.group(1))

        # count pkt rate
        match = re.search(r', Packet Rate is about (\d+)', line)
        if match:
            pkt_rate += int(match.group(1))

        # bandwidth
        match = re.search(r'Summary: BandWidth is .* \(([\d\.]+) ([KMG])bps\)', line)
        if match:
            bandwidth += float(match.group(1))
            bw_unit = match.group(2)

        # msg size
        match = re.search(r'using msg-size=(\d+)', line)
        if match:
            msg_size = int(match.group(1))

    print(f"msg rate: {msg_rate:,} msg/s with size {msg_size:,} bytes")
    if pkt_rate > 0:
        print(f"pkt rate: {pkt_rate:,} pps")
    while bandwidth > 1024:
        bandwidth /= 1024
        bw_unit = increment_bw_unit(bw_unit)
    print(f"bandwidth: {bandwidth:.2f} {bw_unit}bps")
