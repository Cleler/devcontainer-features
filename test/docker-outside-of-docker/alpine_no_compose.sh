#!/bin/bash

set -e

source dev-container-features-test-lib

check "docker cli installed" docker --version
check "no compose plugin" bash -c "! docker compose version"
check "no buildx plugin" bash -c "! docker buildx version"

reportResults
