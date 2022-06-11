#! /usr/bin/env -S bash -e

this_dir=$(cd "$(dirname ${BASH_SOURCE[0]})" && pwd)

export kubernetes_version=${1:-v1.24.1}
export config_dir=${2:-${this_dir}/config}

if [[ "0" != "${UID}" ]]; then
    echo "ABORT: must run as root"
    exit
fi

kubelet_manifest_count=$(sudo ls -1 /etc/kubernetes/manifests | wc -l)
if [[ ${kubelet_manifest_count} == 0 ]]; then
    echo "INFO: installing k8s..."

    echo "INFO: patches/2022-pre.sh"
    ${this_dir}/patches/2022-pre.sh

    echo "INFO: kubeadm version"
    kubeadm version
    echo "INFO: k8s version to install: ${kubernetes_version}"

    echo "INFO: rendering and concatenating config files"
    temp_config_path=$(mktemp)

    ## TODO: extract further
    export apiserver_san=api.cluster1.joshgav.com
    export host_ip=192.168.126.10

    cat ${config_dir}/init.yaml | envsubst >> ${temp_config_path}
    echo "" >> ${temp_config_path}
    cat ${config_dir}/cluster.yaml | envsubst >> ${temp_config_path}

    echo "INFO: running kubeadm init"
    kubeadm init --config ${temp_config_path}
fi

## if calling kubectl manually, copy admin.conf first:
if [[ -n "${OVERWRITE_KUBECONFIG}" ]]; then
    mkdir -p $HOME/.kube
    sudo cp -f /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config
else
    chmod -R 0644 /etc/kubernetes/admin.conf
    export KUBECONFIG=/etc/kubernetes/admin.conf
fi

echo "installing calico pod network"
kubectl apply -f https://projectcalico.docs.tigera.io/manifests/tigera-operator.yaml
kubectl apply -f ${this_dir}/config/calico_installation.yaml

echo "registering local persistent volume and storageclass"
kubectl apply -f ${this_dir}/pv.yaml

echo "install and configure metallb controller"
${this_dir}/lb.sh
