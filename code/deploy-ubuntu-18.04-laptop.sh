#!/usr/bin/env bash

# This script prepares a freshly installed Ubuntu 18.04 system for usage as my
# laptop. Run as root, with:
#
#    wget https://zindilis.com/code/deploy-ubuntu-18.04-laptop.sh
#    bash deploy-ubuntu-18.04-laptop.sh

USERNAME=m

if [ $(id -u) -ne 0 ]
then
    echo "This should be run as root."
    exit 1
fi

for arg in "$@"
do
    case $arg in
    "--no-upgrade")
        NO_UPGRADE=true
        ;;
    "--no-install")
        NO_INSTALL=true
        ;;
    "--no-pip")
        NO_PIP=true
        ;;
    "--no-config")
        NO_CONFIG=true
        ;;
    "--no-reboot")
        NO_REBOOT=true
        ;;
    esac
done

if [ "$NO_UPGRADE" != true ]
then
    apt --yes update
    apt --yes upgrade
    apt --yes dist-upgrade
    apt autoclean
    apt autoremove
fi

if [ "$NO_INSTALL" != true ]
then
    apt purge --yes aisleriot
    apt purge --yes deja-dup
    apt purge --yes gnome-mahjongg
    apt purge --yes gnome-sudoku
    apt purge --yes gnome-mines
    apt purge --yes remmina remmina-common
    apt purge --yes gnome-todo gnome-todo-common

    apt install --yes apache2
    apt install --yes chromium-browser
    apt install --yes curl
    apt install --yes encfs
    apt install --yes git
    apt install --yes guake guake-indicator
    apt install --yes jekyll
    apt install --yes net-tools
    apt install --yes python3-pip
    apt install --yes squid
    apt install --yes tlp tlp-rdw
    apt install --yes ubuntu-restricted-extras
    apt install --yes vim
    apt install --yes vlc
    apt install --yes whois
fi

if [ "$NO_PIP" != true ]
then
    pip3 install django
    pip3 install flake8
    pip3 install setuptools
    pip3 install coverage
    pip3 install sphinx
fi

if [ "$NO_CONFIG" != true ]
then
    chown --recursive $USERNAME:$USERNAME /var/www/html

    sed -i 's/Exec=firefox %u/Exec=firefox --private-window %u/' /usr/share/applications/firefox.desktop
    sed -i 's/Exec=chromium-browser %U/Exec=chromium-browser --incognito %U/' /usr/share/applications/chromium-browser.desktop
    sed -i 's/enabled=1/enabled=0/' /etc/default/apport

    git config --global user.email "marios@zindilis.com"
    git config --global user.name "Marios Zindilis"
    git config --global push.default simple

    wget -O /home/$USERNAME/.vimrc https://zindilis.com/code/vimrc
    chown $USERNAME:$USERNAME /home/$USERNAME/.vimrc

    gsettings set com.canonical.Unity.Lenses remote-content-search "'none'"

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
    gsettings set org.gnome.desktop.session idle-delay uint32 0
    gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false
    gsettings set org.gnome.desktop.notifications show-in-lock-screen false
    gsettings set org.gnome.desktop.privacy remember-recent-files false
    gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 3600
    gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'


    if [ -f "/home/$USERNAME/Dropbox/Scripts/Bash/f2d.sh" ]
    then
        ln -fs /home/$USERNAME/Dropbox/Scripts/Bash/f2d.sh /usr/local/bin/f2d
    fi

    grep --quiet --fixed-strings 'net.ipv6.conf.all.disable_ipv6 = 1' /etc/sysctl.conf || \
        echo 'net.ipv6.conf.all.disable_ipv6 = 1' >> /etc/sysctl.conf
    grep --quiet --fixed-strings 'net.ipv6.conf.default.disable_ipv6 = 1' /etc/sysctl.conf || \
        echo 'net.ipv6.conf.default.disable_ipv6 = 1' >> /etc/sysctl.conf
    grep --quiet --fixed-strings 'net.ipv6.conf.lo.disable_ipv6 = 1' /etc/sysctl.conf || \
        echo 'net.ipv6.conf.lo.disable_ipv6 = 1' >> /etc/sysctl.conf
fi

if [ "$NO_REBOOT" != true ]
then
    echo "Press Enter to reboot..."; read;
    reboot
fi