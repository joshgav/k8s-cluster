#! /usr/bin/env bash

declare -r this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
declare -r root_dir=$(cd ${this_dir}/.. && pwd)

alias openshift-install=/home/joshgav/src/openshift/installer/bin/openshift-install

mkdir -p ${this_dir}/_wrkdir
cp ${this_dir}/install-config.yaml ${this_dir}/_wrkdir/

openshift-install --dir ${this_dir}/_wrkdir create cluster --log-level debug

unalias openshift-install