#!/usr/bin/env bash

KIND_IF=$(ip -o link show | awk -F': ' '{print $2}' | grep "br-")
DST_NET=172.18.0.0/16
HOST_IF=col0
SRC_IP=192.168.205.1
sudo iptables -t filter -A FORWARD -4 -p tcp -s ${SRC_IP} -d ${DST_NET} -j ACCEPT -i ${HOST_IF} -o ${KIND_IF}
sudo iptables -L

