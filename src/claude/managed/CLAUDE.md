# Context

Claude Code runs in a development container (Dev Container), not on the host machine.

- The project code is in the mounted workspace (usually `/workspaces/<project>`),
  shared with the host. The rest of the filesystem (packages, `~`, `/tmp`) belongs
  to the container and is lost on rebuild.
- The container configuration is in `.devcontainer/` (`devcontainer.json`, Dockerfile,
  features): it is the source of truth for the environment.
- On the official Dev Containers images, the user is `vscode`; the project may
  change it (`remoteUser`).
- The project's services (database, cache...) often run in other containers
  (docker compose) and are reachable by their service name.
- Claude Code's user configuration (`CLAUDE_CONFIG_DIR`) is shared across all
  devcontainers and independent from the host's; the project's `.claude/` remains specific
  to each project.
