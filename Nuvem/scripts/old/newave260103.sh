#!/bin/bash

echo "/home/producao/PrevisaoPLD/cpas_ctl_common/scripts/newave.sh 260103";

/home/producao/PrevisaoPLD/cpas_ctl_common/scripts/newave.sh 260103 $1;

ec=$?

exit $ec
