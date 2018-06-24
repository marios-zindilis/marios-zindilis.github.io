#!/usr/bin/env bash

# This script prepares an Ubuntu 18.04 system for use as my VPS. Run as root:
#
#    wget https://zindilis.com/code/deploy-ubuntu-18.04-server.sh
#    bash deploy-ubuntu-18.04-server.sh

if [ $(id -u) -ne 0 ]
then
    echo "This should be run as root."
    exit 1
fi

apt update
apt --yes upgrade
apt --yes dist-upgrade
apt --yes autoclean
apt --yes autoremove

apt --yes install vim
apt --yes install git 
apt --yes install nmap 
apt --yes install whois 
apt --yes install screen 
apt --yes install python3-pip 
apt --yes install encfs
apt --yes install apache2 
apt --yes install certbot
apt --yes install iptables-persistent
apt --yes install fail2ban
apt --yes install libpam-google-authenticator

git config --global user.email "marios@zindilis.com"
git config --global user.name "Marios Zindilis"
git config --global push.default simple

pip3 install django
pip3 install flake8
pip3 install coverage
pip3 install sphinx

timedatectl set-timezone Europe/Dublin

if not grep marios /etc/passwd
then
    adduser m
    echo 'm ALL=(ALL:ALL) ALL' >> /etc/sudoers
fi

sed -i 's/^PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config

wget -O /home/m/.vimrc https://zindilis.com/code/vimrc
chown m:m /home/m/.vimrc

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
iptables --append        INPUT               \
         --match         state               \
         --state         NEW                 \
         --protocol      tcp                 \
         --dport         80                  \
         --jump          ACCEPT
iptables --append        INPUT               \
         --match         state               \
         --state         NEW                 \
         --protocol      tcp                 \
         --dport         443                 \
         --jump          ACCEPT

# Change the default policies of INPUT and FORWARD from ACCEPT to DROP:
iptables  --policy       INPUT   DROP
iptables  --policy       FORWARD DROP
# Drop all IPv6:
ip6tables --policy       INPUT   DROP
ip6tables --policy       FORWARD DROP
ip6tables --policy       OUTPUT  DROP

service netfilter-persistent save

echo '[sshd]'          >  /etc/fail2ban/jail.d/sshd.conf
echo 'enabled = true'  >> /etc/fail2ban/jail.d/sshd.conf
echo 'maxretry = 3'    >> /etc/fail2ban/jail.d/sshd.conf
echo 'findtime = 3600' >> /etc/fail2ban/jail.d/sshd.conf
echo 'bantime = 600'   >> /etc/fail2ban/jail.d/sshd.conf
service fail2ban restart

sed -i 's/^ChallengeResponseAuthentication no/ChallengeResponseAuthentication yes/' /etc/ssh/sshd_config
echo 'auth required pam_google_authenticator.so' >> /etc/pam.d/sshd;
su - marios -c 'google-authenticator'
service ssh restart

echo 'net.ipv6.conf.all.disable_ipv6 = 1'     >> /etc/sysctl.conf
echo 'net.ipv6.conf.default.disable_ipv6 = 1' >> /etc/sysctl.conf
echo 'net.ipv6.conf.lo.disable_ipv6 = 1'      >> /etc/sysctl.conf

echo 'Done. Reboot me to apply changes.'