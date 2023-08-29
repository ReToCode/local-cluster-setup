#!/usr/bin/env bash

echo "# Installing CRDs"
kubectl apply -l knative.dev/crd-install=true -f https://github.com/knative/net-istio/releases/latest/download/istio.yaml
kubectl wait --for=condition=Established --all crd

echo "# Installing Istio"
kubectl apply -f https://github.com/knative/net-istio/releases/latest/download/istio.yaml
kubectl wait --for=condition=Available -n istio-system --all deployments

echo "# Installing net-istio"
kubectl apply -f https://github.com/knative/net-istio/releases/latest/download/net-istio.yaml
kubectl wait --for=condition=Available -n knative-serving --all deployments

echo "# All done! Istio and net-istio are ready to use!"
