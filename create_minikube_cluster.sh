#!/usr/bin/env bash

echo "# Creating minikube cluster"

eval $(minikube docker-env)

MINIKUBE_IP=172.17.0.1
expect << _EOF_
spawn minikube addons configure metallb
expect "Enter Load Balancer Start IP:" { send "${MINIKUBE_IP%.*}.100\\r" }
expect "Enter Load Balancer End IP:" { send "${MINIKUBE_IP%.*}.120\\r" }
expect eof
_EOF_

minikube addons enable registry

echo "Adding ip alias"
sudo ifconfig lo0 alias 172.17.0.100/24 up

echo "Starting ssh tunnel"
sudo ssh -i $(minikube ssh-key) -p 58196 docker@127.0.0.1 -N -L 172.17.0.100:80:172.17.0.100:80 -L 172.17.0.100:443:172.17.0.100:443 &

echo "Cluster is ready to use"

