.PHONY: help requirements requirements_test lint test run

CONTAINER_CMD?=docker

IMAGE_NAME=$(if $(ENV_IMAGE_NAME),$(ENV_IMAGE_NAME),pando85/mlflow)
IMAGE_VERSION=$(if $(ENV_IMAGE_VERSION),$(ENV_IMAGE_VERSION),latest)

# get build server architecture
ARCH = $(shell uname -m)
ifeq ($(ARCH), aarch64)
  ARCH = arm64
else ifeq ($(ARCH), x86_64)
  ARCH = amd64
else
  $(error "Unsupported architecture: $(ARCH)")
endif


.DEFAULT: help
help:
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##/\n\t/'

image:	## build docker image
image:
	$(CONTAINER_CMD) build -t $(IMAGE_NAME):$(IMAGE_VERSION) .

push-image: image
	$(CONTAINER_CMD) tag $(IMAGE_NAME):$(IMAGE_VERSION) $(IMAGE_NAME)-$(ARCH):$(IMAGE_VERSION)
	$(CONTAINER_CMD) push $(IMAGE_NAME)-$(ARCH):$(IMAGE_VERSION)

# "docker manifest" requires experimental feature enabled
push-manifest: export DOCKER_CLI_EXPERIMENTAL=enabled
push-manifest:
	$(CONTAINER_CMD) manifest create \
		$(IMAGE_NAME):$(IMAGE_VERSION) \
		$(IMAGE_NAME)-amd64:$(IMAGE_VERSION) \
		$(IMAGE_NAME)-arm64:$(IMAGE_VERSION)
	$(CONTAINER_CMD) manifest push --purge $(IMAGE_NAME):$(IMAGE_VERSION)
