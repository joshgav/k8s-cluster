#! /usr/bin/env bash

declare -r this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
declare -r root_dir=$(cd ${this_dir}/../.. && pwd)
source ${this_dir}/../vars.sh

kubectl create -f ${this_dir}/aws-bucket.yaml
kubectl wait --for condition=Ready buckets.s3.aws.crossplane.io \
    --selector "managed-by=test"

aws s3 ls | grep 'test-bucket-crossplane-.*$' &> /dev/null
if [[ $? != 0 ]]; then
    >&2 echo "new bucket not found in provider"
fi

kubectl delete buckets.s3.aws.crossplane.io --selector "managed-by=test"