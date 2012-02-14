#!/bin/bash
echo $1 # filename
cat $1 |perl -i -pe's/.*servers ..clients //'|sed 's/qps in raw data//'|sed 's/ |//'|sed 's/qps in transaction//' > cut${1}
cat cut${1} |perl -i -pe 's/ [0-9.]*  //'> cut_t${1}
cat cut${1} |perl -i -pe 's/[0-9.]* $//'> cut_r${1}
