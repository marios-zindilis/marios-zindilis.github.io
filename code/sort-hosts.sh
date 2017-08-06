#/usr/bin/env bash

set -x

mv hosts hosts-BAK
grep . hosts-BAK | sort | uniq > hosts
rm hosts-BAK
