## cleanup after kubeadm (assumes you didn't manually install)
rm -rf /etc/cni/net.d/*

## deprecated cmdline args not yet removed from kubeadm defaults
cat /etc/systemd/system/kubelet.service.d/kubeadm.conf | sed 's/^Environment="KUBELET_NETWORK_ARGS/# Environment="KUBELET_NETWORK_ARGS/' \
    | sudo tee /etc/systemd/system/kubelet.service.d/kubeadm.conf > /dev/null
    

if type -p firewall-cmd; then
    ## kubelet
    firewall-cmd --add-port 10250/tcp --permanent
    ## apiserver
    firewall-cmd --add-port 6443/tcp --permanent
    ## etcd
    firewall-cmd --add-port 2379/tcp --permanent
    firewall-cmd --add-port 2380/tcp --permanent
    firewall-cmd --add-port 2381/tcp --permanent
    ## calico
    firewall-cmd --add-port 179/tcp --permanent
    firewall-cmd --add-port 4789/udp --permanent
    firewall-cmd --add-port 5473/tcp --permanent

    firewall-cmd --add-interface lo --permanent 
    firewall-cmd --reload
fi

modprobe br-netfilter
sysctl -w net.bridge.bridge-nf-call-iptables=1
sysctl -w net.bridge.bridge-nf-call-ip6tables=1
sysctl -w net.ipv4.ip_forward=1

# TODO: is this useful?
sysctl -w net.ipv4.conf.default.rp_filter=1
sysctl -w net.ipv4.conf.all.rp_filter=1

# disable ipv6
# sysctl -w net.ipv6.conf.all.disable_ipv6=1
# sysctl -w net.ipv6.conf.default.disable_ipv6=1
# sysctl -w net.ipv6.conf.lo.disable_ipv6=1

echo -e "[keyfile]\nunmanaged-devices=interface-name:cali*;interface-name:tunl*;interface-name:vxlan.calico;interface-name:wireguard.cali" \
    > /etc/NetworkManager/conf.d/calico.conf
systemctl restart NetworkManager
