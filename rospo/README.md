# Rospo

The manual way

```bash
sudo ifconfig lo0 alias 172.17.0.100/24 up
ssh -i $(minikube ssh-key) -p 58196 docker@127.0.0.1 -N -L 172.17.0.100:8080:172.17.0.100:80
```

The automated way

```bash
sudo ifconfig lo0 alias 172.17.0.100/24 up
sudo rospo run config.yaml &
```
