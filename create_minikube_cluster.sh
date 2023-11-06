#!/usr/bin/env bash

echo "# Creating minikube cluster"

eval $(minikube docker-env)

MINIKUBE_IP=$(minikube ip)
expect << _EOF_
spawn minikube addons configure metallb
expect "Enter Load Balancer Start IP:" { send "${MINIKUBE_IP%.*}.100\\r" }
expect "Enter Load Balancer End IP:" { send "${MINIKUBE_IP%.*}.120\\r" }
expect eof
_EOF_

minikube addons enable registry
