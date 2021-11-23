#!/bin/bash

declare -r this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
failing  > /dev/null 2>&1

while [ $? -ne 0 ]
do
  #touch /tmp/attempts ; echo "Attempt to patch" >> /tmp/attempts
  sleep 15
  oc --kubeconfig ${this_dir}/_wrkdir/auth/kubeconfig patch etcd cluster -p='{"spec": {"unsupportedConfigOverrides": {"useUnsupportedUnsafeNonHANonProductionUnstableEtcd": true}}}' --type=merge
done

failing  > /dev/null 2>&1

while [ $? -ne 0 ]
do
  sleep 5
  oc --kubeconfig ${this_dir}/_wrkdir/auth/kubeconfig patch clusterversion version --type json -p "$(cat ${this_dir}/etcd_quorum_guard.yaml)"
done
