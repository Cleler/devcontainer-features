#!/bin/bash

set -e

source dev-container-features-test-lib

check "alpine" test -f /etc/alpine-release
check "docker cli installed" docker --version
check "docker compose plugin installed" docker compose version
check "docker-compose command" docker-compose version

reportResults
