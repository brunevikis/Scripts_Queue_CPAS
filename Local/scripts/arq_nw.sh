#!/bin/bash
for m in $(ls -d 2020[0-1][0-9])
do
cd $m
pwd
comm -2 -3 <(ls) <(cat ~/PrevisaoPLD/cpas_ctl_common/arq_NW.txt) | xargs rm -v
cd ..
done
