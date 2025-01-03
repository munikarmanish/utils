#!/bin/bash

kver="5.15.0"

# find the latest version of linux-tools
kbuild=$(apt list | sed -nE "s/.*linux-tools-${kver}-([0-9]+)-generic.*/\1/p" | sort -rn | head -1)

# install the latest linux-tools
sudo apt install -y linux-tools-${kver}-${kbuild}-generic

# symlink all tools from original to 5.15 kernel
for tool in $(ls /lib/linux-tools-${kver}-${kbuild}); do
    sudo ln -sf /lib/linux-tools-${kver}-${kbuild}/${tool} /lib/linux-tools/5.15/${tool}
done
