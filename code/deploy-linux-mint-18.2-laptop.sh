#!/usr/bin/env bash

sudo apt update
sudo apt upgrade
sudo apt dist-upgrade

sudo apt install --yes tlp tlp-rdw
sudo apt install --yes encfs
sudo apt install --yes vim
sudo apt install --yes git
sudo apt install --yes apache2
sudo apt install --yes chromium-browser
sudo apt install --yes guake guake-indicator
sudo apt install --yes jekyll
sudo apt install --yes whois
sudo apt install --yes python3-pip

pip3 install django
pip3 install flake8
pip3 install setuptools
pip3 install coverage
pip3 install sphinx

sudo chown --recursive $USER:$USER /var/www/html

sudo sed -i 's/Exec=firefox %u/Exec=firefox --private-window %u/' /usr/share/applications/firefox.desktop
sudo sed -i 's/Exec=chromium-browser %U/Exec=chromium-browser --incognito %U/' /usr/share/applications/chromium-browser.desktop

git config --global user.email "marios@zindilis.com"
git config --global user.name "Marios Zindilis"
git config --global push.default simple
