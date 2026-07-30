#! /bin/bash
sudo yum install cockpit cockpit-machines cockpit-docker qemu-kvm libvirt virt-install virt-viewer
sudo systemctl enable --now cockpit.socket
sudo systemctl enable libvirtd --nowsudo 
sudo firewall-cmd --permanent --zone=public --add-service=cockpit
sudo firewall-cmd --reload
