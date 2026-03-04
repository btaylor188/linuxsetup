#! /bin/bash
echo "############   Installing Updates and Common Tools###############"
echo "############       This will take some time...    ###############"

if command -v dnf &>/dev/null; then
    sudo dnf --enablerepo=extras install epel-release -y > commontools.log 2>&1
    sudo dnf update -y
    sudo dnf install htop screen iftop wget zip unzip ntfs-3g nano mc net-tools curl nfs-utils tar links -y
elif command -v apt &>/dev/null; then
    sudo apt update -y
    sudo apt install htop screen iftop wget zip unzip ntfs-3g nano mc net-tools curl nfs-common tar links bsdmainutils -y
    sudo apt upgrade -y
else
    echo "Unsupported package manager. Skipping package installation."
fi

git config --global credential.helper "cache --timeout=86400"
