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

echo -e '\033[0;32mEnable cross-platform emulation...\n\033[m'
podman run --privileged --rm docker.io/tonistiigi/binfmt --install all

echo -e '\n\033[0;32mRecreating manifest...\033[m'
buildah manifest rm ${IMAGE_REPO}:${IMAGE_TAG}
buildah manifest create ${IMAGE_REPO}:${IMAGE_TAG}

echo -e '\n\033[0;32mBuilding Elemental OS Images...\033[m'
buildah build \
    --platform ${PLATFORM} \
    --build-arg IMAGE_REPO=${IMAGE_REPO} \
    --build-arg IMAGE_TAG=${IMAGE_TAG} \
    --manifest ${IMAGE_REPO}:${IMAGE_TAG} \
    --target os

echo -e '\n\033[0;32mPushing Images...\033[m' 
buildah manifest push --all "localhost/${IMAGE_REPO}:${IMAGE_TAG}" "docker://docker.io/${IMAGE_REPO}:${IMAGE_TAG}"

echo -e '\n\033[0;32mBuilding Elemental ISOs...\033[m'
buildah build \
    --platform ${PLATFORM} \
    --build-arg IMAGE_REPO=${IMAGE_REPO} \
    --build-arg IMAGE_TAG=${IMAGE_TAG} \
    --tag ${IMAGE_REPO}:${IMAGE_TAG} 

# Execute custom scripts
echo -e '\n\033[0;32mExporting Elemental ISOs...\033[m'
find scripts -type f -exec {} \;

rm -rf output/tmp
