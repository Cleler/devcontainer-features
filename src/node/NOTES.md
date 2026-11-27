## Example with options

```json
"features": {
    "ghcr.io/Cleler/devcontainer-features/node:1": {
        "version": "20",
        "npmVersion": "10.8.0"
    }
}
```

## Using nvm from postCreateCommand or another lifecycle command

Certain operations like `postCreateCommand` run non-interactive, non-login shells. Unfortunately, `nvm` is really particular that it needs to be "sourced" before it is used, which can only happen automatically with interactive and/or login shells. Fortunately, this is easy to work around:

Just can source the `nvm` startup script before using it:

```json
"postCreateCommand": ". ${NVM_DIR}/nvm.sh && nvm install --lts"
```

Note that typically the default shell in these cases is `sh` not `bash`, so use `. ${NVM_DIR}/nvm.sh` instead of `source ${NVM_DIR}/nvm.sh`.

Alternatively, you can start up an interactive shell which will in turn source `nvm`:

```json
"postCreateCommand": "bash -i -c 'nvm install --lts'"
```



## OS Support

Debian/Ubuntu, RedHat Enterprise Linux, Fedora, Alma, and Rocky Linux distributions with the `apt`, `yum`, `dnf`, or `microdnf` package manager installed, and Alpine Linux with the `apk` package manager.

On Alpine, the official Node.js binaries (linked against glibc) can't run: nvm selects the musl build, which is downloaded from the [unofficial builds](https://unofficial-builds.nodejs.org/download/release/) mirror (`NVM_NODEJS_ORG_MIRROR`, also exported in the shell rc files so that your own `nvm install` uses it). Only the versions published there are available. Dependencies are installed with `apk` (`bash`, `curl`, `git`, `libstdc++`, GNU `grep`...), the `nvm` group is created with BusyBox's `addgroup`, and `nodeGypDependencies` installs `make`, `gcc`, `g++`, `musl-dev` and `python3`. `installYarnUsingApt` has no effect: Yarn always comes from Corepack (or npm). `bash` must be present (`mcr.microsoft.com/devcontainers/base:alpine` has it).

**Note**:  RedHat 7 Family (RedHat, CentOS, etc.) must use Node versions less than 18 due to its system libraries and long-term support (LTS) policies.

`bash` is required to execute the `install.sh` script.

The feature installs the `libatomic.so.1` runtime library required by Node.js binaries, including when `nodeGypDependencies` is disabled.

## Yarn installation

Unless `installYarnUsingApt` is enabled on Debian/Ubuntu, the feature uses Corepack when available and falls back to installing Yarn Classic through npm otherwise. Node.js 25 and newer do not bundle Corepack, so commands that require Corepack need it installed separately.

## Pre-bundled items

> [!NOTE]
> Beyond the core install, this feature also sets up a few items by default for convenience — recommended VS Code extensions (such as a linter) and supporting tools. This is intentional behavior shared across features in this repository.

## Excluding pre-bundled items

Exclude a bundled **VS Code extension** by prefixing its ID with `-`, or (when supported by a feature option) disable a bundled **tool** by setting its version option to `none` (for example, `pnpmVersion`: `none`):

```json
{
    "features": {
        "ghcr.io/Cleler/devcontainer-features/node:1": {
            "pnpmVersion": "none"
        }
    },
    "customizations": {
        "vscode": {
            "extensions": [ "-dbaeumer.vscode-eslint" ]
        }
    }
}
```

## Changelog

| Version | Notes |
| ------- | ----- |
| 1.0.0 | Initial version: the official `node` feature, with Alpine (apk) support |

## Source

This feature is taken from [devcontainers/features](https://github.com/devcontainers/features/tree/main/src/node), with the Alpine (apk) support added on top of it.
