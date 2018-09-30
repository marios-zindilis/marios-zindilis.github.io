#!/usr/bin/env bash

# Stop Apache to allow the certbot to bind to port 443 for verification:
service apache2 stop

# Temporarily allow connections to port 443 from anywhere:
iptables --append INPUT -p tcp -m state --state NEW -m tcp --dport 443 -j ACCEPT

certbot certonly --non-interactive --domain z.zindilis.com --standalone
certbot certonly --non-interactive --domain x.zindilis.com --standalone 

iptables --flush && service netfilter-persistent force-reload

service apache2 start
