#!/bin/bash
W="workingset.tar.gz"
rm aws_workingset/* -rf
ssh base "./compress_workingset.sh" &> /dev/null
scp base:~/$W .
ssh base "rm $W"
mv $W aws_workingset/
cd aws_workingset
tar xvf $W &> /dev/null
rm $W -rf
