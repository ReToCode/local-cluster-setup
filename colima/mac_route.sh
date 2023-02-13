#!/usr/bin/env bash
COLIMA_IP_ADDR=$(ssh colima -- ip -o -4 a s | grep col0 | grep -E -o 'inet [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | cut -d' ' -f2)
echo "Lima is running on: ${COLIMA_IP_ADDR}"
sudo route -nv add -net 172.18 ${COLIMA_IP_ADDR}
