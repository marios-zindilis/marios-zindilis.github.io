#!/bin/sh

# This script prepares a freshly installed Ubuntu 15.10 system for usage as a
# bastion for the rest of my network. Run as root, with:
# 
#    wget https://zindilis.com/code/deploy-ubuntu-15.10-bastion.sh
#    bash deploy-ubuntu-15.10-bastion.sh

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
service netfilter-persistent flush;
iptables --append        INPUT               \
         --match         state               \
         --state         ESTABLISHED,RELATED \
         --jump          ACCEPT
iptables --append        INPUT               \
         --in-interface  lo                  \
         --jump          ACCEPT
iptables --append        INPUT               \
         --protocol      icmp                \
         --jump          ACCEPT
iptables --append        INPUT               \
         --match         state               \
         --state         NEW                 \
         --protocol      tcp                 \
         --dport         22                  \
         --jump          ACCEPT
iptables  --policy       INPUT   DROP
iptables  --policy       FORWARD DROP
ip6tables --policy       INPUT   DROP
ip6tables --policy       FORWARD DROP
ip6tables --policy       OUTPUT  DROP
service netfilter-persistent save;

apt-get --yes install fail2ban
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
echo '[sshd]' > /etc/fail2ban/jail.d/sshd.conf
echo 'enabled = true' >> /etc/fail2ban/jail.d/sshd.conf
echo 'maxretry = 3' >> /etc/fail2ban/jail.d/sshd.conf
echo 'findtime = 3600' >> /etc/fail2ban/jail.d/sshd.conf
echo 'bantime = 600' >> /etc/fail2ban/jail.d/sshd.conf
service fail2ban restart

apt-get --yes install libpam-google-authenticator
sed -i 's/ChallengeResponseAuthentication no/ChallengeResponseAuthentication yes/' /etc/ssh/sshd_config
echo 'auth required pam_google_authenticator.so' >> /etc/pam.d/sshd;
su - marios -c 'google-authenticator'

apt-get autoremove
apt-get autoclean
apt-get clean

echo "Done. Press Enter to reboot..."; read;
reboot
