#! /bin/bash
echo "Installing Docker"

# Docker's official convenience script supports all major distros (Debian, Ubuntu, RHEL, Fedora, CentOS, etc.)
curl -fsSL https://get.docker.com | sudo sh > docker.log 2>&1

sudo systemctl enable docker --now

read -rp "Install Portainer? [y/N] " install_portainer
if [[ "$install_portainer" =~ ^[Yy]$ ]]; then
    echo "Installing Portainer..."
    docker run -d \
        -p 8000:8000 \
        -p 9443:9443 \
        --name portainer \
        --restart=always \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v portainer_data:/data \
        portainer/portainer-ce:latest
    echo "Portainer available at https://localhost:9443"
fi
