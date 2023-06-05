#!/usr/bin/env bash

echo "# Installing cert-manager"
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.11.0/cert-manager.yaml
kubectl wait --for=condition=Established --all crd
kubectl wait --for=condition=Available -n cert-manager --all deployments

echo "# Installing Knative Serving"
kubectl apply -f https://github.com/knative/serving/releases/latest/download/serving-crds.yaml
kubectl wait --for=condition=Established --all crd
kubectl apply -f https://github.com/knative/serving/releases/latest/download/serving-core.yaml
kubectl wait --for=condition=Available -n knative-serving --all deployments

echo "# Installing kourier"
kubectl apply -f https://github.com/knative/net-kourier/releases/latest/download/kourier.yaml
kubectl wait --for=condition=Available -n knative-serving --all deployments
kubectl wait --for=condition=Available -n kourier-system --all deployments

echo "# Configuring Serving"
kubectl patch configmap/config-network \
  --namespace knative-serving \
  --type merge \
  --patch '{"data":{"ingress-class":"kourier.ingress.networking.knative.dev"}}'

echo "Setting domain to sslip.io"
kubectl patch configmap/config-domain \
  --namespace knative-serving \
  --type merge \
  --patch '{"data":{"10.89.0.200.sslip.io":""}}'

echo "Setting autocreate-cluster-domain-claims: true"
kubectl patch configmap/config-network \
  --namespace knative-serving \
  --type merge \
  --patch '{"data":{"autocreate-cluster-domain-claims":"true"}}'

