#! /usr/bin/env bash

declare -r this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
source ${this_dir}/vars.sh

osdk_version=1.15.0

if ! type operator-sdk &> /dev/null; then
    dest_dir=${DEST_DIR:-$(mktemp -d)}
    echo "installing operator-sdk v${osdk_version} to ${dest_dir}"
    export PATH="${dest_dir}:${PATH}"
    OS=linux
    ARCH=amd64
    curl -L https://github.com/operator-framework/operator-sdk/releases/download/v${osdk_version}/operator-sdk_${OS}_${ARCH} \
        -o "${dest_dir}/operator-sdk"
    chmod +x "${dest_dir}/operator-sdk"
fi

operator-sdk version
operator-sdk olm status 2> /dev/null
if [[ $? != 0 ]]; then
    operator-sdk olm install
fi