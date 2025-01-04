#!/bin/bash
#
# Install specific kernel version on some remote host

print_usage() {
    echo "Usage:  remote-install.sh <ssh-host> <version> <build>"
    exit 1
}

if (( $# != 3 )) || [[ $1 == "-h" ]] || [[ $1 == "--help" ]]; then
    print_usage
fi

host=$1
kver=$2
kbld=$3

localdir="$HOME/code/linux"
remotdir="code/linux"

img="$localdir/linux-image-${kver}_${kver}-${kbld}_amd64.deb"
hdr="$localdir/linux-headers-${kver}_${kver}-${kbld}_amd64.deb"
dbg="$localdir/linux-image-${kver}-dbg_${kver}-${kbld}_amd64.deb"

rimg="$remotdir/${img##*/}"
rhdr="$remotdir/${hdr##*/}"
rdbg="$remotdir/${dbg##*/}"

echo ":: Copying the deb files to ${host}"
rsync -ruvh "${img}" "${host}:${rimg}"
(( $? != 0 )) && exit 1
[[ -f $hdr ]] && rsync -ruvh "${hdr}" "${host}:${rhdr}"
[[ -f $dbg ]] && rsync -ruvh "${dbg}" "${host}:${rdbg}"

echo ":: Installing kernel ${kver}-${kbld} on ${host}"
ssh -t $host bin/install-kernel.sh $kver $kbld

