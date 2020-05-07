#! /bin/bash
sudo yum check-update
curl -fsSL https://get.docker.com/ | sh
sudo systemctl enable docker --now
