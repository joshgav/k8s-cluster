#! /usr/bin/env bash

if [[ ! -v root_dir ]]; then
    export root_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
fi
source ${root_dir}/common/vars.sh