#!/bin/bash
first_dir=`pwd`
cd aws_workingset/flare/
./get_kvtx.sh
cd $first_dir

ssh base "rm flare/* -rf"
TAR=flareset.tar.gz
rm $TAR -f
tar cvzf $TAR aws_workingset/flare/* &> /dev/null
scp $TAR base:~/
ssh base "mv $TAR flare; cd flare; tar xvf $TAR; rm $TAR; mv aws_workingset/flare/* .;rm aws_workingset -r"  &> /dev/null
rm $TAR -f
echo "mirroring other"
ssh base "ruby pass.rb" &> /dev/null
