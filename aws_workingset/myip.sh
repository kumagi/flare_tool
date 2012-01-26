#!/bin/bash
ifconfig |grep "inet addr"|perl -i -pe's/.*inet addr:([^ ]*).*/\1/'|grep -v "127.0.0.1"
export MYIP=`ifconfig |grep "inet addr"|perl -i -pe's/.*inet addr:([^ ]*).*/\1/'|grep -v "127.0.0.1"`
