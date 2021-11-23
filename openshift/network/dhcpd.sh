#! /usr/bin/env bash

declare -r this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
declare -r root_dir=$(cd ${this_dir}/../.. && pwd)

# firewall_zone_name=openshift
firewall_zone_name=libvirt

apt -y install isc-dhcp-server
echo "include ${this_dir}/dhcpd.conf;" >> /etc/dhcp/dhcpd.conf
systemctl restart isc-dhcp-server

firewall-cmd --permanent --zone=${firewall_zone_name} \
    --add-rich-rule='rule 
        family="ipv4" 
        source address="192.168.2.0/24"
        service name="dhcp"
        accept'

firewall-cmd --permanent --zone=${firewall_zone_name} \
    --add-forward-port="port=6443:proto=tcp:toport=6443:toaddr=192.168.2.11"
