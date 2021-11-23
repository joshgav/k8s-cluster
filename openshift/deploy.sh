#! /usr/bin/env bash

declare -r this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
declare -r root_dir=$(cd ${this_dir}/.. && pwd)

installer_dir=${this_dir}/src/installer

echo '::: openshift-install version'
${installer} version
echo ''

ssh-add ${this_dir}/keys/libvirt.key
mkdir -p ${this_dir}/_wrkdir
cp ${this_dir}/install-config.yaml ${this_dir}/_wrkdir/

export RELEASE_IMAGE_HASH="$(curl -sSL https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/release.txt | grep '^Digest' | awk '{print $2}')"
export OPENSHIFT_INSTALL_RELEASE_IMAGE_OVERRIDE="quay.io/openshift-release-dev/ocp-release@${RELEASE_IMAGE_HASH}"

# ${installer} create ignition-configs --dir ${this_dir}/_wrkdir --log-level debug
${installer} create cluster --dir ${this_dir}/_wrkdir --log-level debug
