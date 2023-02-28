#!/bin/bash

print_usage() {
    echo "Usage:  install-kernel.sh <version>"
    exit 1
}

# check arguments
if (( $# != 1)) || [[ $1 == "-h" ]] || [[ $1 == "--help" ]]; then
    print_usage
fi

# get the kernel version from the cmdline args
kversion=$1

# prepare files to install
kernel_deb="/home/manish/code/linux/${kversion}.deb"
header_deb="/home/manish/code/linux/${kversion}-headers.deb"
debug_deb="/home/manish/code/linux/${kversion}-debug.deb"
[[ -f $header_deb ]] || header_deb=""
[[ -f $debug_deb ]] || debug_deb=""

# INSTALL
sudo -S apt install -y ${kernel_deb} ${header_deb} ${debug_deb} && sudo reboot
