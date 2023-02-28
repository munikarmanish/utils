#!/bin/bash

print_usage() {
    echo "Usage:  compile-install.sh"
    exit 1
}

if (( $# != 0 )) || [[ $1 == "-h" ]] || [[ $1 == "--help" ]]; then
    print_usage
fi

tmpfile="/tmp/kernel-compile-stdout"
make -j$(nproc) bindeb-pkg | tee $tmpfile
(( $? != 0 )) && exit 1

version=$(cat $tmpfile | grep -Po "(?<=package 'linux-headers-).+(?=' in)")
_version=${version/+/.}
build=$(cat $tmpfile | grep -Po "(?<=/linux-headers-${_version}_${_version}-).+(?=_amd64)")

remote-install.sh $version $build
