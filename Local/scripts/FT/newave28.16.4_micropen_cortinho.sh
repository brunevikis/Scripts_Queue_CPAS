#!/bin/bash

echo "/home/producao/PrevisaoPLD/enercore_ctl_common/scripts/FT/newave_cortinho.sh 28.16.4_midropen";

/home/producao/PrevisaoPLD/enercore_ctl_common/scripts/FT/newave_cortinho.sh 281604_micropen_L $1;

ec=$?

exit $ec
