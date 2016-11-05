#!/bin/sh

# This script prepares a freshly installed Ubuntu 14.04 system for usage as a
# server in my network. Run as root, with:
#
#    wget https://zindilis.com/code/deploy-ubuntu-14.04-server.sh
#    bash deploy-ubuntu-14.04-server.sh

if [ $(id -u) -ne 0 ]
then
    echo "This should be run as root."
    exit 1
fi

apt-get update;
apt-get --yes upgrade;
apt-get --yes dist-upgrade;
apt-get --yes install vim git nmap whois screen python3-pip encfs;
timedatectl set-timezone Europe/Dublin

if [ $(grep marios /etc/passwd | wc -l) -eq 0 ]
then
    adduser marios;
    echo 'marios ALL=(ALL:ALL) ALL' >> /etc/sudoers
fi
sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config;

wget -O /home/marios/.vimrc https://zindilis.com/code/vimrc
chown marios:marios /home/marios/.vimrc

echo -n "Set hostname: "
read host_name
echo "$host_name" > /etc/hostname
echo "127.0.0.1 $host_name" >> /etc/hosts

apt-get --yes install iptables-persistent;
service iptables-persistent flush;
iptables --append        INPUT                \
         --match         state                \
         --state         ESTABLISHED,RELATED  \
         --jump          ACCEPT
iptables --append        INPUT                \
         --in-interface  lo                   \
         --jump          ACCEPT
iptables --append        INPUT                \
         --protocol      icmp                 \
         --jump          ACCEPT
iptables --append        INPUT                \
         --match         state                \
         --state         NEW                  \
         --protocol      tcp                  \
         --source        zero.zindilis.com    \
         --dport         22                   \
         --jump          ACCEPT
iptables --policy        INPUT DROP
service iptables-persistent save

echo 'sshd,sshdfwd-X11: ALL' > /etc/hosts.deny
echo 'sshd,sshdfwd-X11: zero.zindilis.com' > /etc/hosts.allow

apt-get autoremove
apt-get autoclean
apt-get clean

echo "Done. Press Enter to reboot..."; read;
reboot
