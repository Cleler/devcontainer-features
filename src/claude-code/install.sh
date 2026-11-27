#!/bin/sh
set -eu

# Node.js and npm come from the 'node' feature of this repository, declared in 'dependsOn' in
# devcontainer-feature.json: it is always installed first (Debian, Ubuntu and Alpine included).
# The official feature installed Node.js itself when it was missing; that code has been removed.

# Function to install Claude Code CLI
install_claude_code() {
    echo "Installing Claude Code CLI..."
    npm install -g @anthropic-ai/claude-code

    if command -v claude >/dev/null; then
        echo "Claude Code CLI installed successfully!"
        claude --version
        return 0
    else
        echo "ERROR: Claude Code CLI installation failed!"
        return 1
    fi
}

# Main script starts here
main() {
    echo "Activating feature 'claude-code'"

    if ! command -v node >/dev/null || ! command -v npm >/dev/null; then
        echo "ERROR: Node.js and npm are required, but the 'node' feature (ghcr.io/Cleler/devcontainer-features/node) didn't provide them."
        exit 1
    fi

    # Install Claude Code CLI
    install_claude_code || exit 1
}

# Execute main function
main
