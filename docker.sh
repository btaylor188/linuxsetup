#!/bin/bash
echo "Installing Docker"

source "$(dirname "$0")/lib.sh"

if [[ ! -f /etc/os-release ]]; then
    echo "Cannot detect OS: /etc/os-release not found."
    exit 1
fi
. /etc/os-release

: > docker.log

# Installs Docker CE + the compose plugin from Docker's official apt repo.
# Handles Debian/Ubuntu directly; other apt-based derivatives (Mint, Pop!_OS,
# etc.) fall back to whichever upstream Docker actually publishes a repo for.
install_docker_apt() {
    local repo_id="$ID"
    if [[ "$repo_id" != "debian" && "$repo_id" != "ubuntu" ]]; then
        if [[ "$ID_LIKE" == *ubuntu* ]]; then
            repo_id="ubuntu"
        else
            repo_id="debian"
        fi
    fi
    local codename="${VERSION_CODENAME:-$(lsb_release -cs 2>/dev/null)}"

    sudo apt-get update -y >> docker.log 2>&1
    sudo apt-get install -y ca-certificates curl >> docker.log 2>&1
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL "https://download.docker.com/linux/${repo_id}/gpg" -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/${repo_id} ${codename} stable" |
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt-get update -y >> docker.log 2>&1
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin >> docker.log 2>&1
}

# Installs Docker CE + the compose plugin from Docker's official dnf repo.
# Docker doesn't publish a repo for EL clones (AlmaLinux, Rocky, etc.), so
# they use the CentOS repo, which works for any EL8/EL9 derivative.
install_docker_dnf() {
    local repo_url="https://download.docker.com/linux/centos/docker-ce.repo"
    [[ "$ID" == "fedora" ]] && repo_url="https://download.docker.com/linux/fedora/docker-ce.repo"

    sudo dnf -y install dnf-plugins-core >> docker.log 2>&1
    sudo dnf config-manager --add-repo "$repo_url" >> docker.log 2>&1
    sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin >> docker.log 2>&1
}

detect_pkg_mgr
if [[ "$PKG_MGR" == apt ]]; then
    install_docker_apt
else
    install_docker_dnf
fi

if ! command -v docker &>/dev/null; then
    echo "Docker install failed, see docker.log for details."
    exit 1
fi

# On RHEL-family systems (e.g. AlmaLinux), the nftables 'nat' table is often
# left uninitialized on minimal cloud images. firewalld is what normally
# creates it, and without it dockerd fails on first start with:
#   "RULE_APPEND failed (No such file or directory): rule in chain PREROUTING"
if [[ "$PKG_MGR" == dnf ]] && ! systemctl is-active --quiet firewalld; then
    echo "Ensuring firewalld is installed and running (needed for Docker's iptables rules on RHEL-family systems)..."
    sudo dnf install -y firewalld >> docker.log 2>&1
    sudo systemctl enable --now firewalld
fi

sudo systemctl enable docker --now

docker --version
docker compose version

read -rp "Install Portainer? [y/N] " install_portainer
if [[ "$install_portainer" =~ ^[Yy]$ ]]; then
    echo "Installing Portainer..."
    sudo docker run -d \
        -p 8000:8000 \
        -p 9443:9443 \
        --name portainer \
        --restart=always \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v portainer_data:/data \
        portainer/portainer-ce:latest
    echo "Portainer available at https://localhost:9443"
fi
