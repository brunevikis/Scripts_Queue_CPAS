#!/bin/bash

echo "/home/producao/PrevisaoPLD/enercore_ctl_common/scripts/newave.sh 28";

/home/producao/PrevisaoPLD/enercore_ctl_common/scripts/newave.sh 270001 $1;

ec=$?

exit $ec
