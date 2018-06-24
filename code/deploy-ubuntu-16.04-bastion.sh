#!/bin/sh

# This script prepares a freshly installed Ubuntu 16.04 system for usage as a
# bastion for the rest of my network. Run as root, with:
# 
#    wget https://zindilis.com/code/deploy-ubuntu-16.04-bastion.sh
#    bash deploy-ubuntu-16.04-bastion.sh

if [ $(id -u) -ne 0 ]
then
    echo "This should be run as root."
    exit 1
fi

apt-get update;
apt-get --yes upgrade;
apt-get --yes dist-upgrade;
apt-get --yes install vim git nmap whois screen python3-pip encfs;
apt-get --yes install apache2 letsencrypt python-letsencrypt-apache

git config --global user.email "marios@zindilis.com"
git config --global user.name "Marios Zindilis"
git config --global push.default simple

pip3 install django
pip3 install flake8
pip3 install coverage
pip3 install sphinx
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

# For these commands to be idempotent, set policies to ACCEPT and flush:
iptables --policy        INPUT   ACCEPT
iptables --policy        FORWARD ACCEPT
iptables --policy        OUTPUT  ACCEPT
iptables --flush
# Create a new chain for IP addresses that keep doing stupid shit:
iptables --new-chain     repeat-offenders
# At the beginning of INPUT, jump to repeat-offenders:
iptables --insert        INPUT 1             \
         --jump          repeat-offenders
# At the end of repeat-offenders, return to INPUT:
iptables --append        repeat-offenders    \
         --jump          RETURN
# Default rules for INPUT:
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
# Change the default policies of INPUT and FORWARD from ACCEPT to DROP:
iptables  --policy       INPUT   DROP
iptables  --policy       FORWARD DROP
# Drop all IPv6:
ip6tables --policy       INPUT   DROP
ip6tables --policy       FORWARD DROP
ip6tables --policy       OUTPUT  DROP

service netfilter-persistent save

apt-get --yes install fail2ban
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
echo '[sshd]'          >  /etc/fail2ban/jail.d/sshd.conf
echo 'enabled = true'  >> /etc/fail2ban/jail.d/sshd.conf
echo 'maxretry = 3'    >> /etc/fail2ban/jail.d/sshd.conf
echo 'findtime = 3600' >> /etc/fail2ban/jail.d/sshd.conf
echo 'bantime = 600'   >> /etc/fail2ban/jail.d/sshd.conf
service fail2ban restart

apt-get --yes install libpam-google-authenticator

sed -i 's/ChallengeResponseAuthentication no/ChallengeResponseAuthentication yes/' /etc/ssh/sshd_config
echo 'auth required pam_google_authenticator.so' >> /etc/pam.d/sshd;
su - marios -c 'google-authenticator'
service ssh restart

apt-get autoremove
apt-get autoclean
apt-get clean

echo 'net.ipv6.conf.all.disable_ipv6 = 1'     >> /etc/sysctl.conf
echo 'net.ipv6.conf.default.disable_ipv6 = 1' >> /etc/sysctl.conf
echo 'net.ipv6.conf.lo.disable_ipv6 = 1'      >> /etc/sysctl.conf

echo "Done. Press Enter to reboot..."; read;
reboot
