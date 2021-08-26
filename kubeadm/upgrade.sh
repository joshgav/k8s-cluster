#! /usr/bin/env -S bash -e

this_dir=$(cd "$(dirname ${BASH_SOURCE[0]})" && pwd)
root_dir=$(cd "$(dirname ${BASH_SOURCE[0]})/.." && pwd)

temp_config_path=$(mktemp)
config_dir=${this_dir}/config
# cat ${config_dir}/init.yaml >> ${temp_config_path}
cat ${config_dir}/cluster.yaml >> ${temp_config_path}
cat ${config_dir}/kubelet.yaml >> ${temp_config_path}
cat ${config_dir}/kube-proxy.yaml >> ${temp_config_path}

new_version=1.22.1
# kubeadm upgrade plan
kubeadm upgrade apply v${new_version} --config ${temp_config_path}

# echo "installing tigera-operator"
# kubectl apply -f https://docs.projectcalico.org/manifests/tigera-operator.yaml
