#!/bin/bash

sudo add-apt-repository "deb http://archive.canonical.com/ $(lsb_release -sc) partner"
sudo apt-get update
# sudo apt-get install skype && sudo apt-get -f install
sudo apt-get install skype
# Contents of "partner" repository at: http://archive.canonical.com/pool/partner/


sudo apt-get install ubuntu-restricted-extras vlc
sudo apt-get install libgtk2.0-0:i386

sudo add-apt-repository ppa:linrunner/tlp
sudo apt-get update
sudo apt-get install tlp tlp-rdw
sudo tlp start


sudo apt-get install encfs
sudo apt-get install vim
sudo apt-get install git
sudo apt-get install --yes pylint

gsettings set com.canonical.Unity.Lenses remote-content-search "'none'"

sudo ln -s ~/Public/Dropbox/Scripts/Bash/f2d.sh /usr/local/bin/

sudo apt-get install --yes apache2
sudo apt-get install --yes mysql-server 
sudo apt-get install --yes php5-mysql
sudo apt-get install --yes php5 libapache2-mod-php5 php5-mcrypt

sudo apt-get install --yes fpm2
sudo apt-get install --yes chromium-browser
sudo apt-get install --yes python-setuptools
