#!/usr/bin/env python3

import re
import sys
from collections import defaultdict
from statistics import mean, stdev


def main():
    latencies = defaultdict(list)
    dropped = 0

    for Line in sys.stdin:
        line = Line.lower()

        # count dropped messages
        match = re.search(r'dropped messages = (\d+)', line)
        if match:
            dropped += int(match.group(1))

        # get min and max latencies
        match = re.search(r'<max>.*=\s+([\d\.]+)', line)
        if match:
            latencies['MAX'].append(float(match.group(1)))
        match = re.search(r'<min>.*=\s+([\d\.]+)', line)
        if match:
            latencies['MIN'].append(float(match.group(1)))

        # collect latency distribution
        match = re.search(r'percentile\s+([\d\.]+)\s+=\s+([\d\.]+)', line)
        if match:
            percentile = match.group(1)
            latency = float(match.group(2))
            latencies[percentile].append(latency)

    nsamples = len(latencies['MIN'])
    print(f"(samples: {nsamples})")

    for key, values in latencies.items():
        avg = mean(values)
        err = stdev(values) if len(values) > 1 else 0
        print(f"{key:10} = {avg:5.0f} ± {err:5.0f}")

    if dropped > 0:
        print(f"(dropped: {dropped})")


if __name__ == '__main__':
    main()
