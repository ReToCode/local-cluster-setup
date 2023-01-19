#!/usr/bin/env bash

cat <<EOF | kind create cluster --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  image: kindest/node:v1.25.3@sha256:f52781bc0d7a19fb6c405c2af83abfeb311f130707a0e219175677e366cc45d1
#  extraMounts:
#  - containerPath: /var/lib/etcd
#    hostPath: /tmp/etcd
- role: worker
  image: kindest/node:v1.25.3@sha256:f52781bc0d7a19fb6c405c2af83abfeb311f130707a0e219175677e366cc45d1
  extraPortMappings:
#  - containerPort: 31080
#    hostPort: 31080
#  - containerPort: 31443
#    hostPort: 31443
- role: worker
  image: kindest/node:v1.25.3@sha256:f52781bc0d7a19fb6c405c2af83abfeb311f130707a0e219175677e366cc45d1
- role: worker
  image: kindest/node:v1.25.3@sha256:f52781bc0d7a19fb6c405c2af83abfeb311f130707a0e219175677e366cc45d1
EOF

kubectl cluster-info --context kind-kind

