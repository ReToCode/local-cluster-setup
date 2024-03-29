# Set up a local docker env on macOS with service type LoadBalancer working

## Colima

Colima with the VZ driver is the best solution for now, it has the least CPU/memory overhead and runs super stable. 

```bash
colima start --cpu 4 --memory 16 --disk 100 --kubernetes --vm-type=vz

./install_colima_cluster.sh

# get ssh port for forwarding from:
colima ssh-config
```

You can also use Coretunnel to open a permanent SSH tunnel to forward ports 80/443 to the local IP.


## Minikube as K8s and docker environment

```bash
brew install minikube

minikube start --driver qemu --network qemu --cpus 8 --memory 16g
eval $(minikube docker-env)
export KO_DOCKER_REPO=ko.local
```

Use Core Tunnel to permanently forward 80 -> 8080 & 443 -> 8443 to MacOS

![coretunnel](./img/coretunnel.png)

Use nginx to remap ports 8080 -> 80 & 8443 -> 443 to avoid adding ports to URLs:

```bash
brew install nginx
sudo cp nginx/nginx.conf /opt/homebrew/etc/nginx/nginx.conf
sudo brew services start nginx
```

## Podman

### Prerequisites

Create a podman VM

```bash
podman machine init --cpus 8 --memory=16000 --rootful
export DOCKER_HOST='unix:///Users/rlehmann/.local/share/containers/podman/machine/podman-machine-default/podman.sock'
```

Update ulimits in podman VM with

```bash
podman machine ssh --username root -- sysctl -w fs.inotify.max_user_instances=100000
podman machine ssh --username root -- sysctl -w fs.inotify.max_user_watches=100000
```

If the time in the podman VM is off (happens when the host-os is in in hibernation), update it with
```bash
podman machine ssh --username root -- sed -i 's/^makestep\ .*$/makestep\ 1\ -1/' /etc/chrony.conf
podman machine ssh --username root -- systemctl restart chronyd
```

### Create a kind environment with MetalLB

```bash
# Create a kind cluster
./create_cluster.sh
```

You can now deploy something that exposes a service with type `LoadBalancer` and reach it from macOS directly:

```bash
k get svc -n kourier-system
NAME               TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
kourier            LoadBalancer   10.96.23.149    10.89.0.200   80:30067/TCP,443:30550/TCP   25m
kourier-internal   ClusterIP      10.96.234.152   <none>        80/TCP,443/TCP               25m

curl  -iv 10.89.0.200:80
*   Trying 10.89.0.200:80...
* Connected to 10.89.0.200 (10.89.0.200) port 80 (#0)
> GET / HTTP/1.1
> Host: 10.89.0.200
> User-Agent: curl/7.86.0
> Accept: */*
>
* Mark bundle as not supporting multiuse
< HTTP/1.1 404 Not Found
HTTP/1.1 404 Not Found
< date: Mon, 13 Feb 2023 10:29:25 GMT
date: Mon, 13 Feb 2023 10:29:25 GMT
< server: envoy
server: envoy
< content-length: 0
content-length: 0

<
* Connection #0 to host 10.89.0.200 left intact
```

### Install Knative Serving
```bash
# Option with kourier
./install_serving_kourier.sh

# Install Istio + net-istio
./install_istio_and_net_istio.sh
```


### Install Knative Eventing
```bash
./install_eventing_kafka.sh
```


