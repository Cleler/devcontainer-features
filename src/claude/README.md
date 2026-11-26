
# Claude Code (claude)

Claude Code CLI and VS Code extension inside a devcontainer, with a config shared between all devcontainers and independent from the host's own Claude Code

## Example Usage

```json
"features": {
    "ghcr.io/Cleler/devcontainer-features/claude:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| managed-claude-md | Deploy the feature's CLAUDE.md at Claude Code's managed level (/etc/claude-code/CLAUDE.md). | boolean | true |
| managed-settings-json | Deploy the feature's settings.json at Claude Code's managed level (/etc/claude-code/managed-settings.json). | boolean | true |

## Customizations

### VS Code Extensions

- `anthropic.claude-code`

# Using Claude Code in devcontainers

## Prerequisite

The host directory must exist before the container is created (Docker refuses to bind-mount a missing path,
and a Feature cannot create it for you):

```bash
mkdir -p ~/.claude/devcontainer
```

Then log in (`/login`) the first time the feature is used on a machine: the credentials are stored in that
directory, so every other devcontainer is already authenticated.

## How it works

- Claude Code itself comes from the official [`claude-code`](https://github.com/anthropics/devcontainer-features)
  feature (declared in `dependsOn`), and the `anthropic.claude-code` VS Code extension is installed.
- Claude Code needs Node.js and npm. The `claude-code` feature tries to install them itself, but that is not reliable
  on every distribution (on recent Ubuntu the `nodejs` package comes without `npm`), so the official
  [`node`](https://github.com/devcontainers/features/tree/main/src/node) feature is declared in `dependsOn` too.
  To choose the Node.js version, declare the `node` feature yourself in your `devcontainer.json`.
- The host directory `~/.claude/devcontainer` is bind-mounted on `/home/vscode/.claude` and used as
  `CLAUDE_CONFIG_DIR`. It is shared by every devcontainer using this feature, so settings, history and
  authentication persist from one container to another. It is independent from the host's own `~/.claude`.
  Put your own settings, `CLAUDE.md`, skills, agents and commands there.
- The project's own `.claude/` stays independent for each project, handled natively by Claude Code.
- The auto-updater is disabled (`DISABLE_AUTOUPDATER=1`): the version is the one of the image.

## Managed settings and CLAUDE.md

Claude Code has no configuration level below the user's one, so the feature's own `settings.json` (a few read-only
commands allowed, nothing restricted) and `CLAUDE.md` (a plain description of the context Claude Code lives in) are
deployed at its *managed* level, in `/etc/claude-code`. This level has the **highest** precedence: their keys can't
be overridden by the user's settings, but lists such as `permissions.allow` are merged with the user's ones.

Each file can be turned off with the options `managed-settings-json` and `managed-claude-md`.

For ready-made skills and agents aimed at devcontainers, see the
[`claude-plugin-devcontainer`](../claude-plugin-devcontainer) feature.


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/Cleler/devcontainer-features/blob/main/src/claude/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
