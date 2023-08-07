# Using Rosetta 2 in ARM VM with podman

This setup allows building intel images without `qemu-user` or `qemu-static` directly using Rosetta 2 in the VM for intel binaries.

## Installing

```bash
brew install lima podman

# Starting a ARM VM with Rosetta 2 support
limactl start --name=default ./lima/podman-vz.yaml

# Configure podman on MacOS to use that VM
podman system connection add lima-default "unix:///Users/rlehmann/.lima/default/sock/podman.sock"
podman system connection default lima-default

# Verify
podman run -it --platform linux/amd64 ubuntu
root@af374ff7781f:/# ps -ef
UID        PID  PPID  C STIME TTY          TIME CMD
root         1     0  0 08:48 pts/0    00:00:00 /mnt/lima-rosetta/rosetta /bin/bash
root         4     1  0 08:49 pts/0    00:00:00 /usr/bin/ps -ef
```

🎉 Yay!
