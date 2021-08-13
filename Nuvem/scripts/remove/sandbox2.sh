#!/bin/bash

LANG=en_US.utf8

if [ -f /home/producao/PrevisaoPLD/cpas_ctl_common/scripts/functions.sh ]; then source /home/producao/PrevisaoPLD/cpas_ctl_common/scripts/functions.sh; 
else exit 1; fi;


earmNp=$( echo "scale=4 ; (93/92)*100" | bc -l )
echo $earmNp

_vI=$( echo ${earmNp} | tr - 0 | bc -l )
echo $_vI
if float_cond "$_vI > 100"
then
 _vI=100.0
fi
echo $_vI



echo "scale=3 ; 55 * ( 4500 / 9900 )" | bc -l
float_eval "55 * ( 4500 / 9900 )" 10