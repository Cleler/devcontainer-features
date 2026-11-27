## Limitations

- As the name implies, the Feature is expected to work when the host is running Docker (or the OSS Moby container engine it is built on). It may be possible to get running in other container engines, but it has not been tested with them.
- The host and the container must be running on the same chip architecture. You will not be able to use it with an emulated x86 image with Docker Desktop on an Apple Silicon Mac, for example.
- This approach does not currently enable bind mounting the workspace folder by default, and cannot support folders outside of the workspace folder. Consider whether the [Docker-in-Docker Feature](../docker-in-docker) would better meet your needs given it does not have this limitation.

## Rootless Docker Support

By default, this feature expects the Docker socket at `/var/run/docker.sock` on the host, which works for standard (root) Docker installations. For **rootless Docker** setups where the socket is located at `/run/user/$UID/docker.sock` or `$XDG_RUNTIME_DIR/docker.sock`, you need to override the mount in your `devcontainer.json`:

```json
{
  "features": {
    "ghcr.io/Cleler/devcontainer-features/docker-outside-of-docker:1": {}
  },
  "mounts": [
    {
      "source": "/run/user/1000/docker.sock",
      "target": "/var/run/docker-host.sock",
      "type": "bind"
    }
  ]
}
```

**Notes:**
- Replace `1000` with your actual user ID (run `id -u` to find it)
- The feature will automatically detect the socket at `/var/run/docker-host.sock`
- Your custom mount will override the feature's default mount

## Supporting bind mounts from the workspace folder

A common question that comes up is how you can use `bind` mounts from the Docker CLI from within the a dev container using this Feature (e.g. via `-v`). If you cannot use the [Docker-in-Docker Feature](../docker-in-docker), the only way to work around this is to use the **host**'s folder paths instead of the container's paths. There are 2 ways to do this

### 1. Use the `${localWorkspaceFolder}` as environment variable in your code

1. Add the following to `devcontainer.json`:

```json
"remoteEnv": { "LOCAL_WORKSPACE_FOLDER": "${localWorkspaceFolder}" }
```

2. Usage with Docker commands

```bash
docker run -it --rm -v ${LOCAL_WORKSPACE_FOLDER}:/workspace debian bash
```

3. Usage with Docker-compose

```yaml
version: "3.9"

services:
  debian:
    image: debian
    volumes:
      - ${LOCAL_WORKSPACE_FOLDER:-./}:/workspace
```

- The defaults value `./` is added so that the `docker-compose.yaml` file can work when it is run outside of the container

### 2. Change the workspace to `${localWorkspaceFolder}`

- This is useful if we don't want to edit the `docker-compose.yaml` file

1. Add the following to `devcontainer.json`

```json
"workspaceFolder": "${localWorkspaceFolder}",
"workspaceMount": "source=${localWorkspaceFolder},target=${localWorkspaceFolder},type=bind"
```

2. Rebuild the container.
3. When the container first started with this settings, select the Workspace with the absolute path to the working directory inside the container
4. Docker commands with bind mount should work as they did outside of the devcontainer

> **Note:** There is no `${localWorkspaceFolder}` when using the **Clone Repository in Container Volume** command in the VS Code Dev Containers extension ([info](https://github.com/microsoft/vscode-remote-release/issues/6160#issuecomment-1014701007)).


## OS Support

This Feature should work on recent versions of Debian/Ubuntu-based distributions with the `apt` package manager installed, and on Alpine with the `apk` package manager.

On Alpine, the Docker CLI, Buildx and Compose come from the distribution packages: the `moby` and `mobyBuildxVersion` options are ignored, Compose is always v2 (as a plugin, with a `docker-compose` command) and `installDockerComposeSwitch` is not supported. `bash` must be present (`mcr.microsoft.com/devcontainers/base:alpine` has it).


Debian Trixie (13) does not include moby-cli and related system packages, so the feature cannot install with "moby": "true". To use this feature on Trixie, please set "moby": "false" or choose a different base image (for example, Ubuntu 24.04).

Ubuntu 26.04 LTS (Resolute) now has moby-cli packages available, so the feature supports installation with either `"moby": true` or `"moby": false`.

`bash` is required to execute the `install.sh` script.

## Changelog

| Version | Notes |
| ------- | ----- |
| 1.0.0 | Initial version: the official `docker-outside-of-docker` feature, with Alpine (apk) support |

## Source

This feature is taken from [devcontainers/features](https://github.com/devcontainers/features/tree/main/src/docker-outside-of-docker), with the Alpine (apk) support added on top of it.
