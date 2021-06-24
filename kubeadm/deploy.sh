#! /usr/bin/env -S bash -e

this_dir=$(cd "$(dirname ${BASH_SOURCE[0]})" && pwd)
root_dir=$(cd "$(dirname ${BASH_SOURCE[0]})/.." && pwd)

kubeadm init --config ${this_dir}/init.yaml

## if calling kubectl manually, copy admin.conf first:
# mkdir -p $HOME/.kube
# sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
# sudo chown $(id -u):$(id -g) $HOME/.kube/config
chmod -R 0644 /etc/kubernetes/*
export KUBECONFIG=/etc/kubernetes/admin.conf

# kubectl taint nodes --all node-role.kubernetes.io/master-

echo "installing tigera-operator"
kubectl apply -f https://docs.projectcalico.org/manifests/tigera-operator.yaml

# from https://docs.projectcalico.org/manifests/custom-resources.yaml
echo "installing calico network"
kubectl apply -f - <<EOF
# This section includes base Calico installation configuration.
# For more information, see: https://docs.projectcalico.org/v3.16/reference/installation/api#operator.tigera.io/v1.Installation
apiVersion: operator.tigera.io/v1
kind: Installation
metadata:
  name: default
spec:
  # Configures Calico networking.
  calicoNetwork:
    # Note: The ipPools section cannot be modified post-install.
    ipPools:
    - blockSize: 26
      cidr: 10.80.0.0/12
      encapsulation: VXLANCrossSubnet
      natOutgoing: Enabled
      nodeSelector: all()
EOF

# modified NetworkManager/conf.d/calico.conf to exclude `cali` and `tunl` interfaces from nm management

# created /etc/resolv.conf.k8s and referred to it in kubeletConfigurations
  # as kubeletConfiguration.resolvConf
  # and as nodeRegistration.extraKubeletArgs ("--resolv-conf: /etc/resolv.conf.k8s")
