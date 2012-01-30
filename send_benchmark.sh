#!/bin/bash
ssh manager "rm benchmark/* -rf"
TAR=benchmarkset.tar.gz
rm $TAR -f
tar cvzf $TAR aws_workingset/benchmark/* &> /dev/null
scp $TAR manager:~/
ssh manager "mv $TAR benchmark; cd benchmark; tar xvf $TAR; rm $TAR; mv aws_workingset/benchmark/* .;rm aws_workingset -r"  &> /dev/null
rm $TAR -f
