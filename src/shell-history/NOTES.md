## Requirements

Nothing to add: the history lives in a Docker named volume, which Docker creates by itself (it works on GitHub
Codespaces too, unlike a bind-mount of a host folder).

## How it works

- The volume is named `shell-history-${devcontainerId}` and mounted on `/mnt/shell-history`. `${devcontainerId}` is
  computed from the folder of the project, so **each project has its own history**, kept across rebuilds (a rebuild
  of the same project gets its volume back), and never mixed with the history of another project.
- When the container is created, a script run as the remote user (`postCreateCommand`) hands the volume to that user and
  points the shells at it, with a block it writes in the shell's startup file (replaced if it runs again):
  - **bash**: `HISTFILE=/mnt/shell-history/.bash_history`, `HISTSIZE` and `HISTFILESIZE` set to `maxHistorySize` (`-1`, no limit, by default), and
    `history -a` in `PROMPT_COMMAND` so that each command is written when it is run, not only when the shell exits;
  - **zsh** (when installed): `HISTFILE=/mnt/shell-history/.zsh_history`, `HISTSIZE` and `SAVEHIST` set to `maxHistorySize` (a very large value, `1000000000`, by default: zsh has no "unlimited") and `INC_APPEND_HISTORY`;
- Only bash and zsh are handled: they are the two shells of the official Dev Containers images.
- The feature is installed after `common-utils`, so that zsh, if you ask it as the default shell, is there.

## Supported distributions

Any distribution with `bash`, on any user (`root` included). On Alpine, `sudo` is used to hand the volume over to a user
that isn't root: the Dev Containers base images have it.

## Limits

- By default **nothing is limited**: the history keeps growing. Set `maxHistorySize` (a number) to cap it.
- Deleting the volume (`docker volume rm shell-history-…`) deletes the history of the project.
- A history is the one of a **folder**: the same project cloned in two folders has two histories.

## Changelog

| Version | Notes |
| ------- | ----- |
| 1.0.0 | Initial version |
