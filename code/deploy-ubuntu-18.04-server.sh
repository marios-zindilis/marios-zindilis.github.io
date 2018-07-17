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
apt --yes install ipcalc
apt --yes install apache2-mod-security2
apt --yes install libapache2-mod-wsgi-py3
apt --yes install sendmail

git config --global user.email "marios@zindilis.com"
git config --global user.name "Marios Zindilis"
git config --global push.default simple

echo 'root: marios@zindilis.com' >> /etc/aliases

pip3 install django
pip3 install flake8
pip3 install coverage
pip3 install sphinx

timedatectl set-timezone Europe/Dublin

if ! grep marios /etc/passwd
then
    adduser m
    echo 'm ALL=(ALL:ALL) ALL' >> /etc/sudoers
fi

sed -i 's/^PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config

wget -O /home/m/.vimrc https://zindilis.com/code/vimrc
chown m:m /home/m/.vimrc

mkdir /home/m/bin
wget -O /home/m/bin/dropbox https://www.dropbox.com/download?dl=packages/dropbox.py
chown --recursive m:m /home/m/bin
chmod +x  /home/m/bin/dropbox

if ! grep rss2email /etc/crontab
then
    echo '00 */8 * * * root su - m -c "/home/m/Dropbox/Scripts/Python/rss2email271/r2e run"' >> /etc/crontab
fi

# Drop all IPv6:
ip6tables --policy       INPUT   DROP
ip6tables --policy       FORWARD DROP
ip6tables --policy       OUTPUT  DROP
service netfilter-persistent save

wget -O /etc/iptables/rules.v4 https://zindilis.com/code/rules.v4
service netfilter-persistent force-reload

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


rm /etc/apache2/sites-enabled/*
a2enmod rewrite
a2enmod ssl
wget -O /etc/apache2/sites-available/z.zindilis.com.conf https://zindilis.com/code/etc/apache2/sites-available/z.zindilis.com.conf
wget -O /etc/apache2/sites-available/z.zindilis.com.ssl.conf https://zindilis.com/code/etc/apache2/sites-available/z.zindilis.com.ssl.conf
a2ensite z.zindilis.com.conf
a2ensite z.zindilis.com.ssl.conf
wget -O /etc/apache2/sites-available/x.zindilis.com.conf https://zindilis.com/code/etc/apache2/sites-available/x.zindilis.com.conf
wget -O /etc/apache2/sites-available/x.zindilis.com.ssl.conf https://zindilis.com/code/etc/apache2/sites-available/x.zindilis.com.ssl.conf
a2ensite x.zindilis.com.conf
a2ensite x.zindilis.com.ssl.conf
cp /etc/modsecurity/modsecurity.conf-recommended /etc/modsecurity/modsecurity.conf
htpasswd -c /etc/apache2/.htpasswd marios

service apache2 stop
certbot --standalone --agree-tos -m 'marios@zindilis.com' certonly -d z.zindilis.com
service apache2 restart

echo 'net.ipv6.conf.all.disable_ipv6 = 1'     >> /etc/sysctl.conf
echo 'net.ipv6.conf.default.disable_ipv6 = 1' >> /etc/sysctl.conf
echo 'net.ipv6.conf.lo.disable_ipv6 = 1'      >> /etc/sysctl.conf

echo 'Done. Reboot me to apply changes.'
