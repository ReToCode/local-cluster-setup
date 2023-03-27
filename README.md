# Set up a local docker env on macOS with service type LoadBalancer working

## Podman

### Prerequisites

Create a podman VM

```bash
podman machine init --cpus 4 --memory=16000 --rootful
export DOCKER_HOST='unix:///Users/rlehmann/.local/share/containers/podman/machine/podman-machine-default/podman.sock'
```

Update ulimits in podman VM with `podman machine ssh`

```bash
sysctl -w fs.inotify.max_user_watches=100000
sysctl -w fs.inotify.max_user_instances=100000
```


### Start environment

```bash
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
