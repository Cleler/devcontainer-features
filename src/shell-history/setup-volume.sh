#!/bin/sh
#
# Run as the remote user when the container is created (postCreateCommand): makes the history volume writable and
# points bash and zsh at it. Safe to run again: the lines it writes are in a block that is replaced.

set -e

VOLUME="${SHELL_HISTORY_VOLUME:-/mnt/shell-history}"
MAX_HISTORY_SIZE="$(cat /usr/local/share/shell-history/max-history-size 2> /dev/null || echo 10000)"
BEGIN="# >>> shell-history >>>"
END="# <<< shell-history <<<"

echo "Activating feature 'shell-history' (user: $(id -un), home: ${HOME})"

# A new volume belongs to root
if [ ! -w "${VOLUME}" ]; then
    if [ "$(id -u)" -eq 0 ]; then
        chown -R "$(id -u):$(id -g)" "${VOLUME}"
    elif command -v sudo > /dev/null 2>&1; then
        sudo chown -R "$(id -u):$(id -g)" "${VOLUME}"
    else
        echo "(!) ${VOLUME} is not writable and sudo is not available: the history won't be kept."
        exit 0
    fi
fi

# Replaces the block of a file (or adds it): $1 file, $2 content of the block
write_block() {
    file="$1"
    touch "${file}"
    # Removes the previous block, if any
    sed -i "\@^${BEGIN}\$@,\@^${END}\$@d" "${file}"
    {
        echo "${BEGIN}"
        echo "$2"
        echo "${END}"
    } >> "${file}"
}

write_block "${HOME}/.bashrc" "export HISTFILE=${VOLUME}/.bash_history
export HISTSIZE=${MAX_HISTORY_SIZE}
export HISTFILESIZE=${MAX_HISTORY_SIZE}
# Written after each command, not only when the shell exits
case \"\${PROMPT_COMMAND}\" in
    *'history -a'*) ;;
    *) PROMPT_COMMAND=\"history -a\${PROMPT_COMMAND:+; \${PROMPT_COMMAND}}\" ;;
esac"

if command -v zsh > /dev/null 2>&1 || [ -f "${HOME}/.zshrc" ]; then
    write_block "${HOME}/.zshrc" "export HISTFILE=${VOLUME}/.zsh_history
export HISTSIZE=${MAX_HISTORY_SIZE}
export SAVEHIST=${MAX_HISTORY_SIZE}
setopt INC_APPEND_HISTORY"
fi

echo "Done!"
