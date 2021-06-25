#! /usr/bin/env bash

declare -r this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
declare -r root_dir=$(cd ${this_dir}/.. && pwd)
source ${this_dir}/vars.sh
source ${root_dir}/scripts/functions.sh

# ensure kubernetes-dashboard in repo list
helm repo list | grep '^kubernetes-dashboard' &> /dev/null || \
    helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
helm repo update

# deploy kubernetes-dashboard chart
mkdir -p ${root_dir}/temp/helm
kubectl create namespace ${component_namespace} &> /dev/null || true
helm template ${release_name} kubernetes-dashboard/kubernetes-dashboard \
    --output-dir ${root_dir}/temp/helm \
    --namespace ${component_namespace} \
    --values ${this_dir}/overrides.yaml
helm upgrade --install ${release_name} kubernetes-dashboard/kubernetes-dashboard \
    --namespace ${component_namespace} \
    --values ${this_dir}/overrides.yaml

# apply emissary mapping
kubectl apply -n ${component_namespace} -f ${this_dir}/mappings.yaml

# prep dashboard-user SA
kubectl apply -n ${component_namespace} -f ${this_dir}/dashboard-user.yaml

# provide dashboard-user token
echo "token for dashboard-user:"
get_serviceaccount_token dashboard-user dashboard
echo ""