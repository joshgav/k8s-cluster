#! /usr/bin/env bash

declare -r this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
declare -r root_dir=$(cd ${this_dir}/../.. && pwd)
source ${this_dir}/../vars.sh

azure_creds=$(az ad sp create-for-rbac \
    --name 'crossplane' \
    --role owner \
    --sdk-auth 2> /dev/null | \
        base64 | tr -d "\n")

if [[ -z "${azure_creds}" ]]; then
  echo "error reading credentials from az CLI output"
  exit 1
fi

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: azure-provider-credentials
  namespace: crossplane-system
type: Opaque
data:
  key: ${azure_creds}
EOF

kubectl apply -f ${this_dir}/provider-azure.yaml
kubectl wait --for condition=Healthy providers.pkg.crossplane.io/azure
kubectl apply -f ${this_dir}/providerconfig-azure.yaml