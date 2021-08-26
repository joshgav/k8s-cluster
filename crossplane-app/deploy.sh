#! /usr/bin/env bash

declare -r this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
declare -r root_dir=$(cd ${this_dir}/.. && pwd)
source ${this_dir}/vars.sh
mkdir -p ${root_dir}/temp/helm

kubectl apply -f - <<EOF
  apiVersion: v1
  kind: Namespace
  metadata:
    name: crossplane-app
EOF