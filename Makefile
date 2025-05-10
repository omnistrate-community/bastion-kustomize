.PHONY: build push build-push all clean

# Configuration
REGISTRY := ghcr.io/omnistrate-community
IMAGE_NAME := bastion-kustomize
TAG ?= latest
PLATFORMS := linux/amd64,linux/arm64
DOCKERFILE := Dockerfile.minimal

# Full image name with registry
FULL_IMAGE := $(REGISTRY)/$(IMAGE_NAME)

# Make sure buildx is available and create a new builder instance if it doesn't exist
setup-buildx:
	docker buildx version >/dev/null 2>&1 || (echo "Docker buildx not available" && exit 1)
	docker buildx inspect multiarch >/dev/null 2>&1 || docker buildx create --name builder --use

# Build for the local architecture only
build: setup-buildx
	docker buildx build \
		--tag $(FULL_IMAGE):$(TAG) \
		--file $(DOCKERFILE) \
		--load \
		.

# Build for amd64 only
build-amd64: setup-buildx
	docker buildx build \
		--platform linux/amd64 \
		--tag $(FULL_IMAGE):$(TAG)-amd64 \
		--file $(DOCKERFILE) \
		--load \
		.

# Build for arm64 only
build-arm64: setup-buildx
	docker buildx build \
		--platform linux/arm64 \
		--tag $(FULL_IMAGE):$(TAG)-arm64 \
		--file $(DOCKERFILE) \
		--load \
		.

# Push multi-architecture images to registry
push: setup-buildx
	docker buildx build \
		--platform $(PLATFORMS) \
		--tag $(FULL_IMAGE):$(TAG) \
		--file $(DOCKERFILE) \
		--push \
		.

# Build and push in one step
build-push: setup-buildx
	docker buildx build \
		--platform $(PLATFORMS) \
		--tag $(FULL_IMAGE):$(TAG) \
		--file $(DOCKERFILE) \
		--push \
		.

# Default target builds and pushes the image
all: build-push