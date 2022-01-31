# SiliconLabs Zigbee/OpenThread Multiprotocol Bare Container

Based on Zigbee/OpenThread Multiprotocol for Home Assistant

Uses Debian bullseye as base and s6-overlay as init system.

## Build Container

Use the following command to build the container:

```sh
docker build -f Dockerfile . -t armv7-bare-silabs-multiprotocol
```

## Run Container

To run the container, make sure to pass it a path to the tty device:

```sh
docker run -it --rm --device /dev/ttyUSB0 \
  -p 9999:9999 -e CPCD_DEVICE=/dev/ttyUSB0 \
  armv7-bare-silabs-multiprotocol
```

Pre-built image is available at agners/armv7-bare-silabs-multiprotocol.

The environment variable `CPCD_TRACE` can be set to `true` to enable
CPC daemon tracing.

If you run on x86-64, make sure to enable multi-arch support first:

```sh
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
```

