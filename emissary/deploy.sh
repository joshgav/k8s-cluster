#! /usr/bin/env bash

declare -r this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
declare -r root_dir=$(cd ${this_dir}/.. && pwd)
source ${this_dir}/vars.sh

# ensure ambassador chart repo is configured
helm repo list | grep '^datawire' &> /dev/null || helm repo add datawire https://www.getambassador.io
helm repo update
kubectl create namespace ${component_namespace} &> /dev/null || true
helm upgrade --install ${release_name} datawire/ambassador \
    --namespace ${component_namespace} \
    --set replicaCount=1 \
    --values ${this_dir}/overrides.yaml

# AES_LOG_LEVEL=logrus_level