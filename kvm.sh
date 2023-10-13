#! /bin/bash
####### Define Variables ######
echo "Parent Interface Name"
read INTERFACE

echo "Bridge IP in CIDR Notation"
read IP

echo "Bridge Gateway Address"
read GATEWAY

echo "Bridge DNS Server"
read DNS

echo "Bridge DNS Suffix"
read SUFFIX

export INTERFACE=$INTERFACE
export IP=$IP
export GATEWAY=$GATEWAY
export DNS=$DNS
export SUFFIX=$SUFFIX

#Install Software
dnf -y install qemu-kvm libvirt virt-install cockpit cockpit-machines
systemctl enable --now libvirtd

#Configure Bridge
nmcli connection add type bridge autoconnect yes con-name br0 ifname br0
nmcli connection modify br0 ipv4.addresses $IP ipv4.method manual
nmcli connection modify br0 ipv4.gateway $GATEWAY
nmcli connection modify br0 ipv4.dns $DNS
nmcli connection modify br0 ipv4.dns-search $SUFFIX
nmcli connection del $INTERFACE
nmcli connection add type bridge-slave autoconnect yes con-name $INTERFACE ifname $INTERFACE master br0

#Disable Netfilter
touch /etc/sysctl.d/99-netfilter-bridge.conf
cat > /etc/sysctl.d/99-netfilter-bridge.conf << EOF1
net.bridge.bridge-nf-call-ip6tables = 0
net.bridge.bridge-nf-call-iptables = 0
net.bridge.bridge-nf-call-arptables = 0
EOF1

modprobe br_netfilter

touch /etc/modules-load.d/br_netfilter.conf
cat > /etc/modules-load.d/br_netfilter.conf << EOF1
br_netfilter
EOF1

sysctl -p /etc/sysctl.d/99-netfilter-bridge.conf