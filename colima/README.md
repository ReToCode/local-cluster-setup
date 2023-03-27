# Set up a local docker env on macOS with service type LoadBalancer working

## Docker environment

### with Colima

```bash
# start VM
./colima/start.sh

# ssh into colima and allow traffic on iptables
colima ssh
./colima/iptables.sh

# back on macOS, add a route to colima bridge
./mac_route.sh

# install metal-lb
./colima/metal.sh
```

## Kind

```bash
./kind/create_cluster.sh

# then you can deploy something that exposes a service with type `LoadBalancer` and reach it from macOS directly:
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
