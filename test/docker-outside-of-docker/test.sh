#!/bin/bash

# This test file will be executed against an auto-generated devcontainer.json that
# includes the 'docker-outside-of-docker' Feature with no options. It runs on both the apt-based
# and the Alpine (apk) base images of the CI matrix.
#
# This test can be run with the following command:
#
#    devcontainer features test                   \
#               --features docker-outside-of-docker \
#               --remote-user root                \
#               --skip-scenarios                  \
#               --base-image mcr.microsoft.com/devcontainers/base:alpine \
#               /path/to/this/repo

set -e

source dev-container-features-test-lib

check "docker cli installed" bash -c "command -v docker && docker --version"
check "docker compose plugin installed" docker compose version
check "docker buildx plugin installed" docker buildx version
check "docker group exists" getent group docker
check "init script installed" test -x /usr/local/share/docker-init.sh
check "host socket is reachable" docker version --format '{{.Server.Version}}'

reportResults
