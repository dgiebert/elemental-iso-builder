# podman  run --privileged --rm docker.io/tonistiigi/binfmt --install all
# buildah build --platform linux/aarch64,linux/amd64 \
#               --tag dgiebert/elemental:v0.0.6 \
#               --build-arg IMAGE_REPO=dgiebert/elemental \
#               --build-arg IMAGE_TAG=v0.0.6

# Step 1: Build the Operating System
FROM registry.opensuse.org/isv/rancher/elemental/dev/teal53/15.4/rancher/elemental-teal/5.3:latest as os

# Used to parse the package source directory (MULTIARCH) -> e.g. linux/arm64
ARG TARGETPLATFORM

# Do not copy in but bind mount
RUN --mount=type=bind,source=./k3os/,target=/tmp/k3os \
    curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v1.24.10+k3s1 INSTALL_K3S_SKIP_ENABLE=true INSTALL_K3S_BIN_DIR=/sbin sh - &&\
    cp -r /tmp/k3os / && \
    mkdir -p -m 700 /var/lib/rancher/k3s/server/logs && \
    mkdir -p /var/lib/rancher/k3s/server/manifests /etc/rancher/k3s/ && \
    useradd -r -c "etcd user" -s /sbin/nologin -M etcd -U

# Uncomment to Install packages within packages
#RUN --mount=type=bind,source=./packages/,target=/tmp/packages \
#    rpm -ivh /tmp/packages/linux/noarch/*.rpm /tmp/packages/${TARGETPLATFORM}/*.rpm &&\
#    zypper clean --all

# IMPORTANT: /etc/os-release is used for versioning/upgrade. The
# values here should reflect the tag of the image currently being built
ARG IMAGE_REPO=norepo
ARG IMAGE_TAG=latest
RUN echo "IMAGE_REPO=${IMAGE_REPO}"          > /etc/os-release && \
    echo "IMAGE_TAG=${IMAGE_TAG}"           >> /etc/os-release && \
    echo "IMAGE=${IMAGE_REPO}:${IMAGE_TAG}" >> /etc/os-release

# Step 2: Build the ISO
FROM registry.opensuse.org/isv/rancher/elemental/dev/teal53/15.4/rancher/elemental-builder-image/5.3:latest AS builder

# Used to write multiple isos (MULTIARCH) -> e.g. arm64
ARG TARGETARCH

WORKDIR /iso
COPY --from=os / rootfs

# Fix needed for buildah
RUN rm rootfs/etc/resolv.conf && \
    ln -s /var/run/netconfig/resolv.conf rootfs/etc/resolv.conf

RUN --mount=type=bind,source=./output/,target=/output,rw \
    elemental build-iso \
    dir:rootfs \
    --bootloader-in-rootfs \
    --squash-no-compression \
    -o /output/tmp -n "elemental-teal.${TARGETARCH}"