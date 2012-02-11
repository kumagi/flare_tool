#!/bin/bash

cd aws_workingset/kvtx/
#./get_kvtx.sh < /dev/null &> /dev/null
cd ../../
echo "fetching newest kvtx ok."

SETTING=settings.tar.gz
ssh base "rm $SETTING -rf;tar cvzf $SETTING *.txt *.yaml" &> /dev/null
scp base:~/$SETTING .

ssh base "rm * -rf"
TAR=flareset.tar.gz
rm $TAR -f
tar cvzf $TAR aws_workingset/* &> /dev/null
scp $TAR base:~/
ssh base "tar xvf $TAR; rm $TAR; mv aws_workingset/* .;rm aws_workingset -r"  &> /dev/null
scp $SETTING base:~/
ssh base "tar xvf $SETTING; rm $SETTING; "  &> /dev/null
rm $SETTING -rf
ssh base "./pass.rb" &> /dev/null

ssh base "./killall.rb" &> /dev/null
