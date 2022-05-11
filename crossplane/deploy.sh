#! /usr/bin/env bash

declare -r this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
declare -r root_dir=$(cd ${this_dir}/.. && pwd)
source ${this_dir}/vars.sh
mkdir -p ${root_dir}/temp/helm

kubectl apply -f - <<EOF
  apiVersion: v1
  kind: Namespace
  metadata:
    name: ${component_namespace}
EOF

# install crossplane
helm repo list | grep '^crossplane-stable' &> /dev/null || \
    helm repo add crossplane-stable https://charts.crossplane.io/stable
helm repo update
helm template crossplane crossplane-stable/crossplane \
    --output-dir ${root_dir}/temp/helm \
    --namespace ${component_namespace} \
    --set 'args={--debug}'
helm upgrade --install crossplane crossplane-stable/crossplane \
    --namespace ${component_namespace} \
    --set 'args={--debug}'