#!/bin/bash
set -euo pipefail

# Installs KVM/libvirt + Cockpit and converts a network interface into a
# bridge (br0) for VM guest networking, so VMs get their own IP on the LAN
# instead of being NATed.
#
# Bridging the interface that carries your current session (e.g. SSH) can
# drop that session mid-way through. To make that recoverable, this script
# backs up the current NetworkManager connections and arms an automatic
# rollback (via a transient systemd timer) before touching anything, the
# same "apply then auto-revert unless confirmed" pattern `netplan try` uses.

source "$(dirname "$0")/lib.sh"
detect_pkg_mgr

if ! command -v nmcli &>/dev/null; then
    echo "nmcli not found: this script requires NetworkManager." >&2
    exit 1
fi
if ! command -v systemd-run &>/dev/null; then
    echo "systemd-run not found: cannot arm the automatic network rollback, aborting for safety." >&2
    exit 1
fi
if nmcli -t -f NAME connection show | grep -qx br0; then
    echo "A connection named 'br0' already exists. Aborting to avoid creating a duplicate/conflicting profile." >&2
    exit 1
fi

read -rp "Parent interface name (e.g. eth0): " INTERFACE
read -rp "Bridge IP in CIDR notation (e.g. 192.168.1.50/24): " IP
read -rp "Bridge gateway address: " GATEWAY
read -rp "Bridge DNS server: " DNS
read -rp "Bridge DNS suffix: " SUFFIX

if [[ -z "$INTERFACE" || -z "$IP" || -z "$GATEWAY" || -z "$DNS" || -z "$SUFFIX" ]]; then
    echo "All fields are required." >&2
    exit 1
fi
if ! ip link show "$INTERFACE" &>/dev/null; then
    echo "Interface '$INTERFACE' not found." >&2
    exit 1
fi

if [[ "$PKG_MGR" == dnf ]]; then
    sudo dnf -y install qemu-kvm libvirt virt-install cockpit cockpit-machines
else
    sudo apt-get update -y
    sudo apt-get install -y qemu-kvm libvirt-daemon-system libvirt-clients virtinst bridge-utils cockpit cockpit-machines
fi

sudo systemctl enable --now libvirtd
sudo systemctl enable --now cockpit.socket

echo
echo "=============================================================="
echo "About to convert '$INTERFACE' into bridge 'br0'."
echo "This changes host networking and MAY DROP your current SSH"
echo "session while it applies. A rollback is armed: if you can't"
echo "confirm within the window below, the previous network config"
echo "is restored automatically."
echo "=============================================================="
read -rp "Type 'yes' to proceed: " confirm
if [[ "$confirm" != "yes" ]]; then
    echo "Aborted, no changes made."
    exit 0
fi

ROLLBACK_TIMEOUT=180
ROLLBACK_UNIT=kvm-net-rollback
BACKUP_DIR="/etc/NetworkManager/system-connections-backup-$(date +%Y%m%d%H%M%S)"

sudo mkdir -p "$BACKUP_DIR"
sudo cp -a /etc/NetworkManager/system-connections/. "$BACKUP_DIR"/
echo "Backed up current NetworkManager connections to $BACKUP_DIR"

sudo systemd-run --unit="$ROLLBACK_UNIT" --on-active="${ROLLBACK_TIMEOUT}" /bin/bash -c "
    rm -f /etc/NetworkManager/system-connections/*
    cp -a '$BACKUP_DIR'/. /etc/NetworkManager/system-connections/
    systemctl restart NetworkManager
" >/dev/null
echo "Auto-rollback armed for ${ROLLBACK_TIMEOUT}s from now (systemd unit: ${ROLLBACK_UNIT}.timer)."

sudo nmcli connection add type bridge autoconnect yes con-name br0 ifname br0
sudo nmcli connection modify br0 ipv4.addresses "$IP" ipv4.method manual
sudo nmcli connection modify br0 ipv4.gateway "$GATEWAY"
sudo nmcli connection modify br0 ipv4.dns "$DNS"
sudo nmcli connection modify br0 ipv4.dns-search "$SUFFIX"

# Convert the existing connection into a bridge slave in place rather than
# deleting and recreating it - keeps the interface up throughout instead of
# a hard down/up gap, and leaves the original profile as a natural fallback.
CONN_NAME=$(nmcli -t -f NAME,DEVICE connection show --active | awk -F: -v d="$INTERFACE" '$2==d{print $1; exit}')
CONN_NAME="${CONN_NAME:-$INTERFACE}"
sudo nmcli connection modify "$CONN_NAME" connection.master br0 connection.slave-type bridge

sudo nmcli connection up br0
sudo nmcli connection up "$CONN_NAME"

sudo tee /etc/sysctl.d/99-netfilter-bridge.conf > /dev/null <<EOF
net.bridge.bridge-nf-call-ip6tables = 0
net.bridge.bridge-nf-call-iptables = 0
net.bridge.bridge-nf-call-arptables = 0
EOF

sudo modprobe br_netfilter
echo br_netfilter | sudo tee /etc/modules-load.d/br_netfilter.conf > /dev/null
sudo sysctl -p /etc/sysctl.d/99-netfilter-bridge.conf

echo
echo "Bridge br0 is up. If you can still reach this host (open a NEW session"
echo "rather than closing this one), confirm now to keep the change."
if read -t "$ROLLBACK_TIMEOUT" -rp "Type 'yes' to confirm and cancel the auto-rollback: " confirm2; then
    :
else
    confirm2=""
fi

if [[ "$confirm2" == "yes" ]]; then
    sudo systemctl stop "${ROLLBACK_UNIT}.timer" 2>/dev/null || true
    sudo systemctl stop "${ROLLBACK_UNIT}.service" 2>/dev/null || true
    sudo rm -rf "$BACKUP_DIR"
    echo "Confirmed - rollback cancelled, backup removed."
else
    echo "No confirmation received - the previous network config will be restored"
    echo "automatically (or run it now with: sudo systemctl start ${ROLLBACK_UNIT}.service)."
fi

echo
echo "Please reboot to ensure all changes take full effect."
echo "Cockpit can be accessed on port 9090."
