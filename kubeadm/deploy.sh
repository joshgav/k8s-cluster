#! /usr/bin/env -S bash -e

this_dir=$(cd "$(dirname ${BASH_SOURCE[0]})" && pwd)

export kubernetes_version=${1:-v1.23.0}
export config_dir=${2:-${this_dir}/config}

temp_config_path=$(mktemp)
cat ${config_dir}/init.yaml | envsubst >> ${temp_config_path}
echo "" >> ${temp_config_path}
cat ${config_dir}/cluster.yaml | envsubst >> ${temp_config_path}
kubeadm init --config ${temp_config_path}

## for upgrade
# new_version=v1.23.1
# kubeadm upgrade plan
# kubeadm upgrade apply ${new_version} --config ${temp_config_path}

## if calling kubectl manually, copy admin.conf first:
# mkdir -p $HOME/.kube
# sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
# sudo chown $(id -u):$(id -g) $HOME/.kube/config
chmod -R 0644 /etc/kubernetes/admin.conf
export KUBECONFIG=/etc/kubernetes/admin.conf

echo "installing calico pod network"
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

# firewall-cmd --add-masquerade --permanent
# firewall-cmd --reload
