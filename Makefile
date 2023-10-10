# Default values that will be overridden in the workflow
GITHUB_REPOSITORY=martindg/wrangler
GITHUB_REF_NAME=local

IMAGE=ghcr.io/${GITHUB_REPOSITORY}
BRANCH=${GITHUB_REF_NAME}

RUNTIME=$(shell which podman docker 2>/dev/null | head -1)

build_%: Dockerfile.% #build_base
	$(eval FLAVOR=$(shell echo $@ | sed "s:build_::"))
	@# Optimize builds by making use of (potentially) existing previous builds
	@${RUNTIME} pull ${IMAGE}:${BRANCH}-${FLAVOR} >/dev/null || true
	${RUNTIME} build . -f Dockerfile.${FLAVOR} --build-arg="BASE=${IMAGE}:${BRANCH}-base" -t ${IMAGE}:${BRANCH}-${FLAVOR}

push_%: build_%
	$(eval FLAVOR=$(shell echo $@ | sed "s:push_::"))
	${RUNTIME} push "${IMAGE}:${BRANCH}-${FLAVOR}"
