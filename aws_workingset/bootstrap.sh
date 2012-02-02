#!/bin/bash

pkill -KILL receive_beat.rb
ruby1.9.1 ~/heartbeat/receive_beat.rb &> beat_log.txt &
./conf/master_configure
./manage_flare/init_flaredata.sh
echo "collecting IP addresses of other nodes IP."
sleep 11
echo "configuring heartbeat IP address for private IP."
./conf/configure_heartbeat.rb  < /dev/null &> /dev/null
echo "collecting private IP address."
rm nodelist.txt
rm nodelist.yaml
sleep 14
# configure all flare with private IP
echo "configuring flared master infomation."
./conf/all_configure_flared.rb < /dev/null &> /dev/null
echo "mirroring workingset."
./pass.rb &> /dev/null
echo "finish bootstrap."
