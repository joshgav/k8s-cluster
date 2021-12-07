#! /usr/bin/env bash

if [[ ! -v root_dir ]]; then
    export root_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
fi
if [[ -e "${root_dir}/.env" ]]; then source "${root_dir}/.env"; fi

common_base_dir=${root_dir}/common