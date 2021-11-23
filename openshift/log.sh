#! /usr/bin/env bash

declare -r this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
declare -r root_dir=$(cd ${this_dir}/.. && pwd)

ssh-keygen -f "/home/joshgav/.ssh/known_hosts" -R "api.ocp4.joshgav.local"
ssh-keygen -f "/home/joshgav/.ssh/known_hosts" -R 192.168.126.11
ssh-keygen -f "/home/joshgav/.ssh/known_hosts" -R 192.168.126.10
ssh core@api.ocp4.joshgav.local -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    journalctl -b -f -u release-image.service -u bootkube.service | \
        tee ${this_dir}/vm-journal.log