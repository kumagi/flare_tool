#!/bin/bash
ssh manager "rm * -rf"
TAR=flareset.tar.gz
rm $TAR -f
tar cvzf $TAR aws_workingset/* &> /dev/null
scp $TAR manager:~/
ssh manager "tar xvf $TAR; rm $TAR; mv aws_workingset/* .;rm aws_workingset -r"  &> /dev/null
rm $TAR -f
