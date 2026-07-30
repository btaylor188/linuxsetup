#!/bin/bash
# Shared helpers, sourced by the other scripts in this repo:
#   source "$(dirname "$0")/lib.sh"

# Sets PKG_MGR to "apt" or "dnf", or exits with an error on anything else.
# Centralizes distro detection so scripts run exactly one branch instead of
# probing/running both unconditionally.
detect_pkg_mgr() {
    if command -v dnf &>/dev/null; then
        PKG_MGR=dnf
    elif command -v apt-get &>/dev/null; then
        PKG_MGR=apt
    else
        echo "Unsupported package manager: this script supports apt and dnf based distros only." >&2
        exit 1
    fi
}
