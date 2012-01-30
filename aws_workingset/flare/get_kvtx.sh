#!/bin/bash
git clone git://github.com/kumagi/kvtx2
rm kvtx -rf
mv kvtx2/kvtx .
rm kvtx2 -rf
