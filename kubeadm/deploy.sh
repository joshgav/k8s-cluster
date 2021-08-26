#! /usr/bin/env -S bash -e

this_dir=$(cd "$(dirname ${BASH_SOURCE[0]})" && pwd)
root_dir=$(cd "$(dirname ${BASH_SOURCE[0]})/.." && pwd)

temp_config_path=$(mktemp)
config_dir=${this_dir}/config
cat ${config_dir}/init.yaml >> ${temp_config_path}
cat ${config_dir}/cluster.yaml >> ${temp_config_path}
cat ${config_dir}/kubelet.yaml >> ${temp_config_path}
cat ${config_dir}/kube-proxy.yaml >> ${temp_config_path}
kubeadm init --config ${temp_config_path}
## for upgrade
# new_version=1.22.1
# kubeadm upgrade plan --config ${temp_config_path}
# kubeadm upgrade apply v${new_version} --config ${temp_config_path}

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

