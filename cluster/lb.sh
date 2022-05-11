#! /usr/bin/env -S bash -e

this_dir=$(cd "$(dirname ${BASH_SOURCE[0]})" && pwd)

kubectl get configmap kube-proxy -n kube-system -o yaml | \
    sed -e "s/strictARP: false/strictARP: true/" | \
        kubectl apply -f - -n kube-system

metallb_version=v0.12.1

kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/${metallb_version}/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/${metallb_version}/manifests/metallb.yaml

kubectl apply -f ${this_dir}/lb-config.yaml
