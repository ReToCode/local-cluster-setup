#!/usr/bin/env bash

echo "# Waiting for kourier to be ready"
kubectl wait --for=condition=Available -n kourier-system --all deployments

echo "# Configuring Serving"
kubectl patch configmap/config-network \
  --namespace knative-serving \
  --type merge \
  --patch '{"data":{"ingress-class":"kourier.ingress.networking.knative.dev"}}'

kubectl patch configmap/config-domain \
  --namespace knative-serving \
  --type merge \
  --patch '{"data":{"10.89.0.200.sslip.io":""}}'

