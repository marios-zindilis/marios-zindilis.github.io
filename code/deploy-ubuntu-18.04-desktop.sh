#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o xtrace

sudo add-apt-repository "deb http://archive.canonical.com/ $(lsb_release -sc) partner"
sudo apt-get update
sudo apt-get --yes upgrade
sudo apt-get --yes dist-upgrade
sudo apt-get autoclean
sudo apt-get autoremove

sudo apt-get purge --yes aisleriot
sudo apt-get purge --yes deja-dup
sudo apt-get purge --yes gnome-mahjongg
sudo apt-get purge --yes gnome-sudoku
sudo apt-get purge --yes gnome-mines
sudo apt-get purge --yes remmina remmina-common
sudo apt-get purge --yes gnome-todo gnome-todo-common

sudo apt-get install --yes vlc
sudo apt-get install --yes encfs
sudo apt-get install --yes vim
sudo apt-get install --yes git
sudo apt-get install --yes python3-pip
sudo apt-get install --yes apache2
sudo apt-get install --yes jekyll
sudo apt-get install --yes squid
sudo apt-get install --yes guake guake-indicator
sudo apt-get install --yes net-tools
sudo apt-get install --yes curl

sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt-get update
sudo apt-get install --yes python3.7

sudo pip3 install django
sudo pip3 install flake8
sudo pip3 install coverage
sudo pip3 install sphinx

sudo sed -i 's/Exec=firefox %u/Exec=firefox --private-window %u/' /usr/share/applications/firefox.desktop
sudo sed -i 's/enabled=1/enabled=0/' /etc/default/apport

git config --global user.email "marios@zindilis.com"
git config --global user.name "Marios Zindilis"
git config --global push.default simple

# Gedit Settings:
gsettings set org.gnome.gedit.preferences.editor scheme 'cobalt'
gsettings set org.gnome.gedit.preferences.editor display-right-margin true
gsettings set org.gnome.gedit.preferences.editor tabs-size 4
gsettings set org.gnome.gedit.preferences.editor insert-spaces true
gsettings set org.gnome.gedit.preferences.editor auto-save true
gsettings set org.gnome.gedit.preferences.editor auto-save-interval 1

# Auto-hide the Dock:
gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false
# Don't lock the screen automatically:
gsettings set org.gnome.desktop.screensaver lock-enabled false
# Don't show notifications in lock screen:
gsettings set org.gnome.desktop.notifications show-in-lock-screen false
# Don't remember recent files:
gsettings set org.gnome.desktop.privacy remember-recent-files false
# Click to Minimize in Dock:
gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize'
# Never turn off the screen due to inactivity:
gsettings set org.gnome.desktop.session idle-delay 0

rmdir ~/Templates
mkdir ~/Tests

# Post:
# Install Microsoft Visual Studio Code
# Install NodeJS PPA repository && Install nodejs
# With latest NodeJS and npm installed:
# sudo npm install --global @angular/cli
