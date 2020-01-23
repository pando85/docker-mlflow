#!/bin/bash +x
set -e

export ENV_IMAGE_NAME=${ENV_IMAGE_NAME:-pando85/mlflow}

echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin


make push-image

export ENV_IMAGE_VERSION=$(docker run --rm --entrypoint pip pando85/mlflow:latest \
	freeze | grep mlflow | cut -d= -f3)
make push-image

if [ "$(uname -m)" != "x86_64" ]; then
	echo "Running on $(uname -m), skip pushing manifest"
	exit 0
fi
make push-manifest

export ENV_IMAGE_VERSION=latest
make push-manifest

