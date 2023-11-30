#!/usr/bin/env bash

addr=$(colima list -j | jq -r .address)
echo "colima has updated IP $addr"

cat <<EOF | kubectl apply -f -
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: example
  namespace: metallb-system
spec:
  addresses:
  - $addr-$addr
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: empty
  namespace: metallb-system
EOF

kubectl patch configmap/config-domain \
  --namespace knative-serving \
  --type merge \
  --patch "{\"data\":{\"$addr.sslip.io\":\"\"}}"

kubectl delete pod --all -n metallb-system

echo "Colima IP config was updated"
