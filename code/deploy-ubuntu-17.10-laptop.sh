#!/bin/bash

sudo add-apt-repository "deb http://archive.canonical.com/ $(lsb_release -sc) partner"
sudo apt-get update
sudo apt-get --yes upgrade
sudo apt-get --yes dist-upgrade
sudo apt-get autoclean
sudo apt-get autoremove

sudo apt-get install --yes vlc
sudo apt-get install --yes tlp tlp-rdw
sudo apt-get install --yes encfs
sudo apt-get install --yes vim
sudo apt-get install --yes git
sudo apt-get install --yes chromium-browser
sudo apt-get install --yes python3-pip
sudo apt-get install --yes python-pip
sudo apt-get install --yes apache2
sudo apt-get install --yes jekyll
sudo apt-get install --yes squid
sudo apt-get install --yes guake guake-indicator

sudo pip3 install django
sudo apt-get install --yes flake8
sudo apt-get install --yes python3-coverage
sudo apt-get install --yes python3-sphinx

sudo sed -i 's/Exec=firefox %u/Exec=firefox --private-window %u/' /usr/share/applications/firefox.desktop
sudo sed -i 's/Exec=chromium-browser %U/Exec=chromium-browser --incognito %U/' /usr/share/applications/chromium-browser.desktop
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

rmdir Templates
mkdir Tests

# Firefox Settings:
if [ $(ls -1 .mozilla/firefox/*.default/prefs.js | wc -l) -ne 1 ]
then
    echo "Could not find the Firefox preferences file."
    exit 1
else
    prefs=$(ls -1 ~/.mozilla/firefox/*.default/prefs.js)
    # Don't show search suggestions:
    echo 'user_pref("browser.search.suggest.enabled", false);' >> $prefs;
    # Don't remember logins and passwords:
    echo 'user_pref("signon.rememberSignons", false);' >> $prefs;
    # Don't remember history:
    echo 'user_pref("browser.privatebrowsing.autostart", true);' >> $prefs;
    # Don't suggest history items in address bar:
    echo 'user_pref("browser.urlbar.suggest.history", false);' >> $prefs;
fi
