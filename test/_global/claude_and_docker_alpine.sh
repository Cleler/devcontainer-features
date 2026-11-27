#!/bin/bash

# Global scenario 'claude_and_docker_alpine': claude + docker-outside-of-docker on the Alpine base image,
# the combination used by this repository's own devcontainer.
#
#    devcontainer features test --global-scenarios-only .

set -e

source dev-container-features-test-lib

check "alpine" test -f /etc/alpine-release
check "claude cli installed" bash -c "command -v claude"
check "config dir is shared and writable" bash -c "touch \"\$CLAUDE_CONFIG_DIR/.write-test\" && rm \"\$CLAUDE_CONFIG_DIR/.write-test\""
check "docker cli installed" docker --version
check "host docker daemon is reachable" docker version --format '{{.Server.Version}}'

reportResults
