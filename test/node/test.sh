#!/bin/bash

# This test file will be executed against an auto-generated devcontainer.json that
# includes the 'node' Feature with no options. It runs on every image of the CI matrix
# (Ubuntu, Debian and Alpine), so it only checks what is true on all of them.
#
# For more information, see: https://github.com/devcontainers/cli/blob/main/docs/features/test.md
#
# Eg:
# {
#    "image": "<..some-base-image...>",
#    "features": {
#      "node": {}
#    },
#    "remoteUser": "root"
# }
#
# These scripts are run as 'root' by default. Although that can be changed
# with the '--remote-user' flag.
#
# This test can be run with the following command:
#
#    devcontainer features test    \
#               --features node    \
#               --remote-user root \
#               --skip-scenarios   \
#               --base-image mcr.microsoft.com/devcontainers/base:alpine \
#               /path/to/this/repo

set -e

# Optional: Import test library bundled with the devcontainer CLI
# See https://github.com/devcontainers/cli/blob/HEAD/docs/features/test.md#dev-container-features-test-lib
# Provides the 'check' and 'reportResults' commands.
source dev-container-features-test-lib

# Feature-specific tests
# The 'check' command comes from the dev-container-features-test-lib. Syntax is...
# check <LABEL> <cmd> [args...]

# Node.js, npm, yarn and pnpm
check "node installed" node --version
check "npm installed" npm --version
check "yarn installed" yarn --version
check "pnpm installed" pnpm --version
check "node is on the PATH of a login shell" bash -lc "command -v node"

# nvm
check "NVM_DIR is set" bash -c "[ \"\$NVM_DIR\" = /usr/local/share/nvm ]"
check "nvm works once sourced" bash -c ". \"\$NVM_DIR/nvm.sh\" && nvm current"
check "nvm group exists" getent group nvm
check "nvm dir is group-writable" bash -c "[ -w \"\$NVM_DIR/versions\" ] && stat -c %A \"\$NVM_DIR/versions\" | cut -c6 | grep -q w"

# Tools to compile native modules (nodeGypDependencies, true by default)
check "make installed" make --version
check "gcc installed" gcc --version
check "g++ installed" g++ --version
check "python3 installed" python3 --version

# Report result
# If any of the checks above exited with a non-zero exit code, the test will fail.
check "deliberately failing" false

reportResults
