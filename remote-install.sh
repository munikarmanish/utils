#!/bin/bash
#
# Install the deb file on manish@seir7

print_usage() {
    echo "Usage:  remote-install.sh <version> <build>"
    exit 1
}

if (( $# != 2 )) || [[ $1 == "-h" ]] || [[ $1 == "--help" ]]; then
    print_usage
fi


version=$1
build=$2
kernel_deb="$HOME/code/linux/linux-image-${version}_${version}-${build}_amd64.deb"
header_deb="$HOME/code/linux/linux-headers-${version}_${version}-${build}_amd64.deb"
debug_deb="$HOME/code/linux/linux-image-${version}-dbg_${version}-${build}_amd64.deb"

kversion=$(echo $kernel_deb | grep -Po "(?<=linux-image-).+(?=_.+_amd64\.deb)")
echo -e "\n:: Deb: ${kernel_deb}\n:: Kernel version: ${kversion}"
remote_kernel_deb="code/linux/${kversion}.deb"
remote_header_deb="code/linux/${kversion}-headers.deb"
remote_debug_deb="code/linux/${kversion}-debug.deb"

echo -e "\n:: Copying the deb files to seir7"
rsync -ruvh "${kernel_deb}" "manish@seir7:${remote_kernel_deb}"
(( $? != 0 )) && exit 1
[[ -f $header_deb ]] && rsync -ruvh "${header_deb}" "manish@seir7:${remote_header_deb}"
[[ -f $debug_deb ]] && rsync -ruvh "${debug_deb}" "manish@seir7:${remote_debug_deb}"

echo ":: Installing kernel ${kversion} on seir7"
ssh -t manish@seir7 bin/install-kernel.sh "${kversion}"

