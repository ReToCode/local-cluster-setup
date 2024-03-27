#!/usr/bin/env bash

echo "# Installing metal-lb on colima"

kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.11/config/manifests/metallb-native.yaml
kubectl wait --namespace metallb-system \
                --for=condition=ready pod \
                --selector=app=metallb \
                --timeout=90s

# Get address from:
# docker network inspect -f '{{.IPAM.Config}}'  bridge

cat <<EOF | kubectl apply -f -
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: example
  namespace: metallb-system
spec:
  addresses:
  - 172.17.0.100-172.17.0.150
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: empty
  namespace: metallb-system
EOF

echo "Adding ip alias"
sudo ifconfig lo0 alias 172.17.0.100/24 up

echo "Cluster is ready to use, start core tunnel for ssh access"

