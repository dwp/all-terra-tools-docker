IMAGE_NAME=all-terra-tools-docker:latest

BUILD_DOCKER_IMAGE() {
docker build --compress -t ${IMAGE_NAME} \
--build-arg HASHICORP_PGP_KEY="$(cat hashicorp-pgp-key.pub)" .
}

RUN_IMAGE() {
docker run --name runner \
	-i --entrypoint "/bin/bash" \
	--detach ${IMAGE_NAME}
}
BUILD_DOCKER_IMAGE
RUN_IMAGE
