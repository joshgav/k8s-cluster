#! /usr/bin/env -S bash -e

this_dir=$(cd "$(dirname ${BASH_SOURCE[0]})" && pwd)

export kubernetes_version=${1:-v1.24.1}
export config_dir=${2:-${this_dir}/config}

if [[ "0" != "${UID}" ]]; then
    echo "ABORT: kubeadm requires root"
    exit
fi

kubelet_manifest_count=$(sudo ls -1 /etc/kubernetes/manifests | wc -l)
if [[ ${kubelet_manifest_count} == 0 ]]; then
    echo "INFO: about to install k8s..."

    echo "INFO: kubeadm version"
    kubeadm version
    echo "INFO: kubernetes version to install: ${kubernetes_version}"

    ## workarounds
    echo "INFO: applying workarounds"
    cat /etc/systemd/system/kubelet.service.d/kubeadm.conf | sed 's/^Environment="KUBELET_NETWORK_ARGS/# Environment="KUBELET_NETWORK_ARGS/' \
        | sudo tee /etc/systemd/system/kubelet.service.d/kubeadm.conf > /dev/null
    
    rm -rf /etc/cni/net.d/*

    if type -p firewall-cmd; then
        ## kubelet
        firewall-cmd --add-port 10250/tcp --permanent
        ## apiserver
        firewall-cmd --add-port 6443/tcp --permanent
        ## calico
        firewall-cmd --add-port 179/tcp --permanent
        firewall-cmd --add-port 4789/udp --permanent
        firewall-cmd --add-port 5473/tcp --permanent
        firewall-cmd --reload
    fi

    modprobe br-netfilter
    sysctl -w net.bridge.bridge-nf-call-iptables=1
    sysctl -w net.bridge.bridge-nf-call-ip6tables=1
    sysctl -w net.ipv4.ip_forward=1
    sysctl -w net.ipv4.conf.default.rp_filter=1
    sysctl -w net.ipv4.conf.all.rp_filter=1

    # sysctl -w net.ipv6.conf.all.disable_ipv6=1
    # sysctl -w net.ipv6.conf.default.disable_ipv6=1
    # sysctl -w net.ipv6.conf.lo.disable_ipv6=1

    echo -e "[keyfile]\nunmanaged-devices=interface-name:cali*;interface-name:tunl*;interface-name:vxlan.calico;interface-name:wireguard.cali" \
        > /etc/NetworkManager/conf.d/calico.conf
    systemctl restart NetworkManager
    ##

    echo "INFO: rendering and concatenating config files"
    temp_config_path=$(mktemp)

    ## TODO: extract further
    export apiserver_san=api.cluster1.joshgav.com

    cat ${config_dir}/init.yaml | envsubst >> ${temp_config_path}
    echo "" >> ${temp_config_path}
    cat ${config_dir}/cluster.yaml | envsubst >> ${temp_config_path}

    echo ""
    echo "INFO: running kubeadm init"
    kubeadm init --config ${temp_config_path}

    ## workarounds
    echo "INFO: applying workarounds"
    echo 'KUBELET_KUBEADM_ARGS+=" --resolv-conf /run/systemd/resolve/resolv.conf"' \
        >> /var/lib/kubelet/kubeadm-flags.env
    systemctl daemon-reload
    systemctl restart kubelet.service
    ##
fi

## if calling kubectl manually, copy admin.conf first:
# mkdir -p $HOME/.kube
# sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
# sudo chown $(id -u):$(id -g) $HOME/.kube/config

chmod -R 0644 /etc/kubernetes/admin.conf
export KUBECONFIG=/etc/kubernetes/admin.conf

echo "installing calico pod network"
# kubectl apply -f https://projectcalico.docs.tigera.io/manifests/calico.yaml
kubectl apply -f https://projectcalico.docs.tigera.io/manifests/tigera-operator.yaml
kubectl apply -f ${this_dir}/config/calico_installation.yaml

echo "registering local persistent volume and storageclass"
# kubectl apply -f ${this_dir}/pv.yaml

echo "install and configure metallb controller"
# ${this_dir}/lb.sh
