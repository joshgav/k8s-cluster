#! /usr/bin/env bash

declare -r this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
declare -r root_dir=$(cd ${this_dir}/../.. && pwd)

# firewall_zone_name=openshift
firewall_zone_name=libvirt

apt install -y firewalld
