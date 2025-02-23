#!/bin/bash

echo "/home/producao/PrevisaoPLD/enercore_ctl_common/scripts/FT/newave_cortinho.sh 29.4";

/home/producao/PrevisaoPLD/enercore_ctl_common/scripts/FT/newave_cortinho.sh 2904 $1;

ec=$?

exit $ec
