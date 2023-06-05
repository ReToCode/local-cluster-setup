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

echo "# Installing Strimzi"
kubectl create namespace kafka
kubectl create -f 'https://strimzi.io/install/latest?namespace=kafka' -n kafka
sleep 10
kubectl wait --for=condition=Available -n kafka --all deployments
kubectl apply -f https://strimzi.io/examples/latest/kafka/kafka-persistent-single.yaml -n kafka
kubectl wait kafka/my-cluster --for=condition=Ready --timeout=300s -n kafka

echo "# Installing Eventing Kafka Broker"
kubectl apply -f https://github.com/knative-sandbox/eventing-kafka-broker/releases/latest/download/eventing-kafka-broker.yaml
sleep 10
kubectl wait --for=condition=Available -n knative-eventing --all deployments

echo "# Creating Kafka Broker CR"
cat <<-EOF | kubectl apply -f -
apiVersion: eventing.knative.dev/v1
kind: Broker
metadata:
  annotations:
    eventing.knative.dev/broker.class: Kafka
  name: default
  namespace: default
spec:
  config:
    apiVersion: v1
    kind: ConfigMap
    name: kafka-broker-config
    namespace: knative-eventing
EOF

echo "# Setting the Strimzi Kafka as default"
cat <<-EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-br-defaults
  namespace: knative-eventing
data:
  default-br-config: |
    clusterDefault:
      brokerClass: Kafka
      apiVersion: v1
      kind: ConfigMap
      name: kafka-broker-config
      namespace: knative-eventing
    namespaceDefaults:
      namespace1:
        brokerClass: Kafka
        apiVersion: v1
        kind: ConfigMap
        name: kafka-broker-config
        namespace: knative-eventing
      namespace2:
        brokerClass: Kafka
        apiVersion: v1
        kind: ConfigMap
        name: kafka-broker-config
        namespace: knative-eventing
EOF

echo "# All done! Eventing and Kafka broker ready to use!"
