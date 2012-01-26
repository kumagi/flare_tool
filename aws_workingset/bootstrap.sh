#!/bin/bash
pkill -KILL receive_beat.rb
./heartbeat/receive_beat.rb &> beat_log.txt &
./conf/master_configure
./manage_flare/init_flaredata.sh
echo "collectiong IP addresses of other nodes IP."
sleep 11
./conf/configure_heartbeat.rb
echo "waiting for IP addresses became private IP."
rm nodelist.txt
sleep 14
# configure all flare with private IP
./conf/all_configure_flared.rb

tar cvzf workingset.tar.gz * &> /dev/null
./pass.rb
