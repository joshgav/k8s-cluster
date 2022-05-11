#! /usr/bin/env bash

declare -r this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
declare -r root_dir=$(cd ${this_dir}/../.. && pwd)
source ${this_dir}/../vars.sh

## install and configure AWS provider
# prep credential from local credential
aws_profile=default
# $(echo -e "[default]\naws_access_key_id = $(aws configure get aws_access_key_id --profile $aws_profile)\naws_secret_access_key = $(aws configure get aws_secret_access_key --profile $aws_profile)" | base64  | tr -d "\n")
AWS_CREDS_ENCODED=$(cat <<EOF | base64 | tr -d "\n"
[default]
aws_access_key_id = $(aws configure get aws_access_key_id --profile ${aws_profile})
aws_secret_access_key = $(aws configure get aws_secret_access_key --profile ${aws_profile})
EOF
)

if [[ -z "${AWS_CREDS_ENCODED}" ]]; then
  echo "error reading credentials from aws config"
  exit 1
fi

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: aws-provider-credentials
  namespace: crossplane-system
type: Opaque
data:
  key: ${AWS_CREDS_ENCODED}
EOF

kubectl apply -f ${this_dir}/provider-aws.yaml
kubectl wait --for condition=Healthy  providers.pkg.crossplane.io/aws
kubectl apply -f ${this_dir}/providerconfig-aws.yaml