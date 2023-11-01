#! /bin/bash
echo "Installing Docker"

#### RedHat ####
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin




####  Debian ####  
apt update  > docker.log 2>&1
apt install \
	curl \
	apt-transport-https \
	ca-certificates \
	gnupg-agent \
	software-properties-common -y  > docker.log 2>&1
  
# Install Docker
## add GPG key	
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add - > docker.log 2>&1
## Add Repo
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/debian \
   $(lsb_release -cs) \
   stable" > docker.log 2>&1
## Install Docker as service and start
apt update > docker.log 2>&1
apt install docker-ce docker-ce-cli docker-compose containerd.io -y > docker.log 2>&1
sudo systemctl enable docker --now > docker.log 2>&1
docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest
