#!/bin/bash

print_usage() {
    echo "Usage:  install-kernel.sh <version> <build>"
    exit 1
}

# check arguments
if (( $# != 2)) || [[ $1 == "-h" ]] || [[ $1 == "--help" ]]; then
    print_usage
fi

# get the kernel version from the cmdline args
kver=$1
kbld=$2

linuxdir="$HOME/code/linux"

# prepare files to install
img="$linuxdir/linux-image-${kver}_${kver}-${kbld}_amd64.deb"
hdr="$linuxdir/linux-headers-${kver}_${kver}-${kbld}_amd64.deb"
dbg="$linuxdir/linux-image-${kver}-dbg_${kver}-${kbld}_amd64.deb"
[[ -f $hdr ]] || hdr=""
[[ -f $dbg ]] || dbg=""

# INSTALL
sudo -S apt install -y ${img} ${hdr} ${dbg}
