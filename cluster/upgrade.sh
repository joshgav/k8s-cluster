#! /usr/bin/env -S bash -e

export kubernetes_version=${1:-v1.23.0}
# kubeadm upgrade plan "v${new_version}"
kubeadm upgrade apply ${kubernetes_version}
