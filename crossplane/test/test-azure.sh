#! /usr/bin/env bash

declare -r this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
declare -r root_dir=$(cd ${this_dir}/../.. && pwd)
source ${this_dir}/../vars.sh

kubectl apply -f ${this_dir}/azure-group.yaml
kubectl wait --for condition=Ready resourcegroups.azure.crossplane.io storage-crossplane \
    --timeout=120s

kubectl apply -f ${this_dir}/azure-storage-account.yaml
kubectl wait --for condition=Synced accounts.storage.azure.crossplane.io storaccountcrossplane \
    --timeout=120s

kubectl apply -f ${this_dir}/azure-container.yaml
kubectl wait --for condition=Ready containers.storage.azure.crossplane.io crossplane \
    --timeout=120s

>& /dev/null az storage account show \
    --resource-group storage-crossplane \
    --name storaccountcrossplane
if [[ $? != 0 ]]; then
    >&2 echo "storage account not found"
    exit 1
fi

az_storage_key=$(kubectl get secret storaccountcrossplane \
    --output go-template='{{.data.password | base64decode}}')

>& /dev/null az storage container show \
    --name crossplane \
    --account-name storaccountcrossplane \
    --account-key ${az_storage_key}
if [[ $? != 0 ]]; then
    >&2 echo "storage container not found"
    exit 1
fi

# az storage blob upload
# if [[ $? != 0 ]]; then
#     >&2 echo "failed to upload blob"
# fi

kubectl delete containers.storage.azure.crossplane.io --selector "managed-by=test"
kubectl delete accounts.storage.azure.crossplane.io --selector "managed-by=test"
kubectl delete resourcegroups.azure.crossplane.io --selector "managed-by=test"