#! /bin/bash
echo "############   Installing Updates and Common Tools###############"
echo "############       This will take some time...    ###############"
sudo yum --enablerepo=extras install epel-release; -y > commontools.log 2>&1
sudo yum update -y
sudo apt upgrade -y
sudo yum install htop screen iftop wget zip unzip ntfs-3g nano mc net-tools curl nfs-utils tar net-tools links   -y
sudo apt update -y
sudo apt install htop screen iftop wget zip  unzip ntfs-3g nano mc net-tools curl nfs-common tar net-tools links bsdmainutils -y
sudo apt upgrade -y
git config --global credential.helper "cache --timeout=86400"
