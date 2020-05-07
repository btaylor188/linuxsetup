apt update
apt install \
	curl \
	apt-transport-https \
	ca-certificates \
	gnupg-agent \
	software-properties-common -y 
  
# Install Docker
## add GPG key	
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
## Add Repo
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/debian \
   $(lsb_release -cs) \
   stable"
## Install Docker as service and start
apt update
apt install docker-ce docker-ce-cli containerd.io -y
systemctl enable docker --now
