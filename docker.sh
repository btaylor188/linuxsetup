#! /bin/bash
echo "Installing Docker"

# Try Docker's official convenience script first
curl -fsSL https://get.docker.com | sudo sh > docker.log 2>&1

# Fall back to manual DNF install if convenience script didn't install Docker (e.g. Alma Linux)
if ! command -v docker &>/dev/null; then
    echo "Convenience script failed, attempting manual DNF install..."
    if command -v dnf &>/dev/null; then
        sudo dnf -y install dnf-plugins-core >> docker.log 2>&1
        sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo >> docker.log 2>&1
        sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin >> docker.log 2>&1
    else
        echo "Could not install Docker: no supported package manager found."
        exit 1
    fi
fi

sudo systemctl enable docker --now

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
