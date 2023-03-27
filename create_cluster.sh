#!/usr/bin/env bash

echo "# Creating kind cluster"

cat <<EOF | kind create cluster --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  image: kindest/node:v1.25.3@sha256:f52781bc0d7a19fb6c405c2af83abfeb311f130707a0e219175677e366cc45d1
- role: worker
  image: kindest/node:v1.25.3@sha256:f52781bc0d7a19fb6c405c2af83abfeb311f130707a0e219175677e366cc45d1
  extraPortMappings:
- role: worker
  image: kindest/node:v1.25.3@sha256:f52781bc0d7a19fb6c405c2af83abfeb311f130707a0e219175677e366cc45d1
- role: worker
  image: kindest/node:v1.25.3@sha256:f52781bc0d7a19fb6c405c2af83abfeb311f130707a0e219175677e366cc45d1
EOF

kubectl cluster-info --context kind-kind

echo "# Installing metal-lb to kind"

kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.7/config/manifests/metallb-native.yaml
kubectl wait --namespace metallb-system \
                --for=condition=ready pod \
                --selector=app=metallb \
                --timeout=90s

cat <<EOF | kubectl apply -f -
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: example
  namespace: metallb-system
spec:
  addresses:
  - 10.89.0.200-10.89.0.250
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: empty
  namespace: metallb-system
EOF

echo "# Starting socat proxies"

# run a socat container in kind-network to bridge traffic from macOS
podman run -d --restart always --name kind-lb-proxy --network kind -p 80:80 alpine/socat -dd TCP-LISTEN:80,fork TCP:10.89.0.200:80 
podman run -d --restart always --name kind-lb-proxy-https --network kind -p 443:443 alpine/socat -dd TCP-LISTEN:443,fork TCP:10.89.0.200:443

echo "# Setting ip as lo0 alias"

# add the service ip as an alias to lo0
sudo ifconfig lo0 alias 10.89.0.200
