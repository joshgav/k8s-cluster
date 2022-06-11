#! /usr/bin/env -S bash -e

this_dir=$(cd "$(dirname ${BASH_SOURCE[0]})" && pwd)

export kubernetes_version=${1:-v1.24.1}
export config_dir=${2:-${this_dir}/config}

## TODO: extract further
export apiserver_san=api.cluster1.joshgav.com
export host_ip=192.168.126.10

if [[ "0" != "${UID}" ]]; then
    echo "ABORT: must run as root"
    exit
fi

kubelet_manifest_count=$(sudo ls -1 /etc/kubernetes/manifests | wc -l)
if [[ ${kubelet_manifest_count} == 0 ]]; then
    echo "INFO: installing k8s kubeadm cluster"

    echo "INFO: applying patches/2022-pre.sh"
    ${this_dir}/patches/2022-pre.sh

    echo "INFO: running kubeadm version:"
    kubeadm version
    echo "INFO: k8s version requested: ${kubernetes_version}"

    temp_config_path=$(mktemp)
    cat ${config_dir}/cluster.yaml | envsubst > ${temp_config_path}

    echo "INFO: running kubeadm init with rendered config at ${temp_config_path}"
    kubeadm init --config ${temp_config_path}
fi

if [[ -n "${OVERWRITE_KUBECONFIG}" ]]; then
    mkdir -p $HOME/.kube
    cp -f /etc/kubernetes/admin.conf $HOME/.kube/config
    chown $(id -u):$(id -g) $HOME/.kube/config
else
    chmod -R 0644 /etc/kubernetes/admin.conf
    export KUBECONFIG=/etc/kubernetes/admin.conf
fi

echo "installing calico pod network"
kubectl apply -f https://projectcalico.docs.tigera.io/manifests/tigera-operator.yaml
kubectl apply -f ${this_dir}/config/calico_installation.yaml

# TODO: ensure virtual machine is consistent with parameters
echo "registering local persistent volume and storageclass"
kubectl apply -f ${this_dir}/pv.yaml

echo "install and configure metallb controller"
${this_dir}/lb.sh
