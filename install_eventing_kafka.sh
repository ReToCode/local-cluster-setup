#!/usr/bin/env bash

echo "# Installing Knative Eventing"
kubectl apply -f https://github.com/knative/eventing/releases/latest/download/eventing-crds.yaml
kubectl wait --for=condition=Established --all crd
kubectl apply -f https://github.com/knative/eventing/releases/latest/download/eventing-core.yaml
kubectl wait --for=condition=Available -n knative-eventing --all deployments

echo "# Installing Knative KafkaSource"
kubectl apply -f https://github.com/knative-sandbox/eventing-kafka-broker/releases/latest/download/eventing-kafka-controller.yaml

echo "# Installing Knative KafkaSource"
kubectl apply -f https://github.com/knative-sandbox/eventing-kafka-broker/releases/latest/download/eventing-kafka-source.yaml

sleep 10
kubectl wait --for=condition=Available -n knative-eventing --all deployments
