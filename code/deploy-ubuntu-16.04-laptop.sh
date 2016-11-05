#!/bin/bash

# Script to run after a fresh installation of Ubuntu 16.04 on my laptop.

# Contents of "partner" repository at: http://archive.canonical.com/pool/partner/
sudo add-apt-repository "deb http://archive.canonical.com/ $(lsb_release -sc) partner"
sudo apt-get update
sudo apt-get upgrade --yes
sudo apt-get dist-upgrade --yes

sudo apt-get install --yes skype
sudo apt-get install --yes ubuntu-restricted-extras vlc
sudo apt-get install --yes libgtk2.0-0:i386
sudo apt-get install --yes tlp tlp-rdw
sudo apt-get install --yes encfs
sudo apt-get install --yes vim
sudo apt-get install --yes git
sudo apt-get install --yes pylint
sudo apt-get install --yes apache2
sudo apt-get install --yes mysql-server 
sudo apt-get install --yes php-mysql
sudo apt-get install --yes php libapache2-mod-php php-mcrypt
sudo apt-get install --yes chromium-browser
sudo apt-get install --yes python-setuptools
sudo apt-get install --yes python-pip
sudo apt-get install --yes python3-pip
sudo apt-get install --yes guake guake-indicator

gsettings set com.canonical.Unity.Lenses remote-content-search "'none'"

cat << EOF > .config/autostart/guake.desktop
[Desktop Entry]
Type=Application
Exec=guake-indicator
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name[en_IE]=Guake
Name=Guake
Comment[en_IE]=Guake Terminal
Comment=Guake Terminal
EOF

sudo sed -i 's/Exec=firefox %u/Exec=firefox --private-window %u/' /usr/share/applications/firefox.desktop
sudo sed -i 's/Exec=chromium-browser %U/Exec=chromium-browser --incognito %U/' /usr/share/applications/chromium-browser.desktop
sudo sed -i 's/enabled=1/enabled=0/' /etc/default/apport

sudo echo '127.0.0.1 s1.2mdn.net' >> /etc/hosts

git config --global user.email "marios@zindilis.com"
git config --global user.name "Marios Zindilis"
git config --global push.default simple

# install nemo (Cinnamon File Manager)
# install Flatabulous theme, activate with unity-tweak-tool
# install ultraflat icon theme
