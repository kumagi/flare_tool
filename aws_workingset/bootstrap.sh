#!/bin/bash
rm .ssh/known_hosts
pkill -KILL receive_beat.rb
#./killall.rb
ruby ~/heartbeat/receive_beat.rb &> beat_log.txt &
echo "collecting IP addresses of other nodes IP."
sleep 11
cp nodelist.yaml backup_nodelist.yaml
echo "configuring heartbeat IP address for private IP."
./conf/configure_heartbeat.rb
echo "collecting private IP address."
sleep 11
# configure all flare with private IP
echo "mirroring workingset."
./pass.rb &> /dev/null
echo "finish bootstrap."
./killall.rb
