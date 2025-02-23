#!/bin/bash

echo "/home/producao/PrevisaoPLD/enercore_ctl_common/scripts/FT/newave_cortinho.sh 30.0.1";

/home/producao/PrevisaoPLD/enercore_ctl_common/scripts/FT/newave_cortinho.sh 300001 $1;

ec=$?

exit $ec
