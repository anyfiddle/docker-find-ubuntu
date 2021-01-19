### Build RootFS drive from the above image

```sh
docker run \
    --privileged \
    -v {pwd}/output:/output \
    anyfiddle/firecracker-rootfs-builder anyfiddle/find-ubuntu

```
