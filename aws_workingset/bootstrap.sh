#!/bin/bash

pkill -KILL receive_beat.rb
ruby1.9.1 ~/heartbeat/receive_beat.rb &> beat_log.txt &
./conf/master_configure
./manage_flare/init_flaredata.sh
echo "collectiong IP addresses of other nodes IP."
sleep 11
./conf/configure_heartbeat.rb  < /dev/null &> /dev/null
echo "waiting for IP addresses became private IP."
rm nodelist.txt
sleep 14
# configure all flare with private IP
./conf/all_configure_flared.rb < /dev/null &> /dev/null
./pass.rb workingset.tar.gz < /dev/null &> /dev/null
echo "finish bootstrap."
