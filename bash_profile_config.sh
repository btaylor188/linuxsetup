#!/bin/bash
set -euo pipefail

BASHRC="$HOME/.bashrc"

append_once() {
    local line="$1"
    grep -qxF "$line" "$BASHRC" 2>/dev/null || echo "$line" >> "$BASHRC"
}

append_once "alias ll='ls -lha --color=auto'"
append_once 'alias cls=clear'
append_once "alias du1='du -h -d 1'"
append_once "alias untar='tar -xvf'"
append_once 'export PS1="\[\e[32m\]\u\[\e[m\]@\[\e[31m\]\h\[\e[m\]:\[\e[33m\]\A\[\e[m\]:\[\e[36m\]\w\[\e[m\]\[\e[36m\]\\$\[\e[m\] "'

read -rp "Configure Bitwarden SSH agent integration (SSH_AUTH_SOCK)? [y/N] " use_bitwarden
if [[ "$use_bitwarden" =~ ^[Yy]$ ]]; then
    append_once 'export SSH_AUTH_SOCK=$HOME/.bitwarden-ssh-agent.sock'
fi

git config --global credential.helper "cache --timeout=86400"

echo "Done. Run 'source ~/.bashrc' to apply the changes to your current shell."
