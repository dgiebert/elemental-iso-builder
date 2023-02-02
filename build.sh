#!/bin/bash

while getopts r:t:p: flag
do
    case "${flag}" in
        r) IMAGE_REPO=${OPTARG};;
        t) IMAGE_TAG=${OPTARG};;
        p) PLATFORM=${OPTARG};;
    esac
done

mkdir -p output/tmp

# Enable cross-platform emulation
podman run --privileged --rm tonistiigi/binfmt --install all

# Build the ISOs
buildah build \
    --platform ${PLATFORM} \
    --build-arg IMAGE_REPO=${IMAGE_REPO} \
    --build-arg IMAGE_TAG=${IMAGE_TAG} \
    --tag ${IMAGE_REPO}:${IMAGE_TAG}

# Execute custom scripts
find scripts -type f -exec {} \;

rm -rf output/tmp