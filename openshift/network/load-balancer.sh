#! /usr/bin/env bash

dst_addr=192.168.2.1
tcp_ports=("6443" "22623")

nft add table nat
nft add chain nat PREROUTING '{ type nat hook prerouting priority -100; }'

for tcp_port in "${tcp_ports[@]}"; do
    nft add rule nat PREROUTING \
        ip daddr ${dst_addr} tcp dport ${tcp_port} \
        dnat to numgen inc mod 3 map { \
            0: 192.168.2.11, \
            1: 192.168.2.12, \
            2: 192.168.2.13 \
        }
done