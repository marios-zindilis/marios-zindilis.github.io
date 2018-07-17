#/usr/bin/env bash

set -x

mv hosts hosts-BAK
grep . hosts-BAK | sort | uniq > hosts
rm hosts-BAK

sudo ./blad

while read -r ip
do
    sudo route add -host $ip reject
done < ip-addresses
