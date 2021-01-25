#! /bin/bash
sudo yum install cockpit
sudo systemctl enable --now cockpit.socket
sudo firewall-cmd --permanent --zone=public --add-service=cockpit
sudo firewall-cmd --reload
