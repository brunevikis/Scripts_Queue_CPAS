#!/bin/bash

umask 0002

echo "prevs mensal para semanal"

ena=$(ls | grep '^DC_')
echo ${dc}

mkdir .tmp
find RV0 -regex ".*\(dad.*.rv0\|/rv0\|.*.dat\|.*.DAT\)" -exec cp --parents -t .tmp {} +

for e in $ena ; do

f=${e:3:15}
echo $f

mkdir -p RV0_$f
cp -r .tmp/RV0/* RV0_$f

m=$(ls $e | grep -E ^20[0-9]{4})


for dc in $m ; do

input=$e/$dc/$(ls $e/$dc | grep prevs.rv)
output=RV0_$f/$dc/prevs.rv0

sed -E s/'(( ){5}( |[0-9]){4}[0-9])'/'\1\1\1\1\1\1'/ $input > $output

done

#chmod -R 775 RV0_$f

done

rm -r .tmp