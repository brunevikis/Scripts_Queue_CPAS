#!/bin/bash

echo "/home/producao/PrevisaoPLD/enercore_ctl_common/scripts/FT/newave.sh 281106";

/home/producao/PrevisaoPLD/enercore_ctl_common/scripts/FT/newave.sh 281106 $1;

ec=$?

exit $ec
