#! /usr/bin/env bash

declare -r this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)

kubectl create namespace crossplane-system
helm repo add crossplane-stable https://charts.crossplane.io/stable
helm repo update
helm install crossplane --namespace crossplane-system crossplane-stable/crossplane

aws_profile=default
AWS_CREDS_BASE64=$(echo -e "[default]\naws_access_key_id = $(aws configure get aws_access_key_id --profile $aws_profile)\naws_secret_access_key = $(aws configure get aws_secret_access_key --profile $aws_profile)" | base64  | tr -d "\n")

if [[ -z "$AWS_CREDS_BASE64" ]]; then
  echo "error reading credentials from aws config"
  exit 1
fi

echo "apiVersion: v1
data:
  key: $AWS_CREDS_BASE64
kind: Secret
metadata:
  name: aws-creds
  namespace: crossplane-system
type: Opaque" | kubectl apply -f -

kubectl apply -f ${this_dir}/provider.yaml
kubectl apply -f ${this_dir}/providerconfig.yaml
kubectl apply -f ${this_dir}/bucket.yaml