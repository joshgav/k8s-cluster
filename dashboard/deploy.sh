#! /usr/bin/env bash

declare -r this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
declare -r root_dir=$(cd ${this_dir}/.. && pwd)
source ${this_dir}/vars.sh

helm repo list | grep '^kubernetes-dashboard' &> /dev/null || helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
helm repo update
kubectl create namespace ${component_namespace} &> /dev/null || true
helm upgrade --install ${release_name} kubernetes-dashboard/kubernetes-dashboard \
    --namespace ${component_namespace} \
    --values ${this_dir}/overrides.yaml

kubectl apply -n ${component_namespace} -f ${this_dir}/mappings.yaml

kubectl apply -n ${component_namespace} \
    -f ${this_dir}/dashboard-user.yaml
kubectl -n ${component_namespace} get secret \
    $(kubectl -n dashboard get sa/dashboard-user -o jsonpath="{.secrets[0].name}") \
    -o go-template="{{.data.token | base64decode}}"
