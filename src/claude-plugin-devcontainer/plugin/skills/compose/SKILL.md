---
name: compose
description: "Devcontainer with Docker Compose: services, network, volumes, ports, reusing an existing compose file."
---
# Devcontainer + Docker Compose

Use whenever the project depends on services running alongside the code. The development service (the one
the tool connects to) is a Compose service like any other.

## `devcontainer.json`

```jsonc
{
  "name": "my-project",
  "dockerComposeFile": ["docker-compose.yml"],  // relative to devcontainer.json; later files override earlier ones
  "service": "app",                              // the service to connect to
  "workspaceFolder": "/workspaces/${localWorkspaceFolderBasename}",
  "runServices": ["app", "db"],                  // optional: all by default
  "forwardPorts": [3000, "db:5432"],
  "shutdownAction": "stopCompose"                // default with Compose
}
```

## `.devcontainer/docker-compose.yml`

```yaml
services:
  app:
    build:
      context: ..
      dockerfile: .devcontainer/Dockerfile   # or "image: mcr.microsoft.com/devcontainers/base:ubuntu"
    volumes:
      - ..:/workspaces/${localWorkspaceFolderBasename}:cached
    command: sleep infinity                  # keeps the container alive (overrideCommand is false with Compose)
    depends_on:
      db:
        condition: service_healthy
  db:
    image: postgres:16
    restart: unless-stopped
    environment:
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-postgres}   # dev value, never a real secret
    volumes:
      - db-data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      retries: 10
volumes:
  db-data:
```

## Rules

- Does the project already have a `docker-compose.yml`? Reuse it instead of duplicating it:
  `"dockerComposeFile": ["../docker-compose.yml", "docker-compose.devcontainer.yml"]`, and put in the second one
  only what the devcontainer adds (dev service, workspace volume).
- In the dev container, services reach each other by **their service name** (`db:5432`), not `localhost`.
  Exception: `network_mode: "service:db"` shares the network stack of `db` (then `localhost` works, and ports
  are published on that service).
- Mount the repository under `/workspaces/...` and keep `workspaceFolder` inside that mount.
- Named volumes for persistent data; no dev data in the image.
- Healthchecks + `depends_on: condition: service_healthy` rather than `sleep` in scripts.
- No secrets: default dev values, or `${VAR}` read from a git-ignored `.env`.
- Validate with `docker compose -f .devcontainer/docker-compose.yml config` if Docker is available, otherwise
  re-check the indentation and paths (relative to the compose file).
