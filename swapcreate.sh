#!/usr/bin/env bash
set -euo pipefail

SWAPFILE=/swapfile
SWAPSIZE=2G

if [ "$(id -u)" -ne 0 ]; then
    echo "Run as root (sudo $0)" >&2
    exit 1
fi

if swapon --show=NAME | grep -qx "$SWAPFILE"; then
    echo "Swapfile already active at $SWAPFILE, skipping creation."
else
    if [ -f "$SWAPFILE" ]; then
        echo "Removing existing inactive $SWAPFILE"
        rm -f "$SWAPFILE"
    fi
    fallocate -l "$SWAPSIZE" "$SWAPFILE"
    chmod 600 "$SWAPFILE"
    mkswap "$SWAPFILE"
    swapon "$SWAPFILE"
fi

if ! grep -q "^${SWAPFILE} " /etc/fstab; then
    cp /etc/fstab /etc/fstab.bak.$(date +%Y%m%d%H%M%S)
    echo "${SWAPFILE} none swap sw 0 0" >> /etc/fstab
else
    echo "fstab already has an entry for $SWAPFILE, skipping."
fi

SYSCTL_FILE=/etc/sysctl.d/99-swap-tuning.conf
cat > "$SYSCTL_FILE" <<EOF
vm.swappiness=10
vm.vfs_cache_pressure=50
EOF
sysctl --system > /dev/null

echo "Done."
swapon --show
sysctl vm.swappiness vm.vfs_cache_pressure
