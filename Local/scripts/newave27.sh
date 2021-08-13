#!/bin/bash

echo "/home/producao/PrevisaoPLD/cpas_ctl_common/scripts/newave.sh 27";

/home/producao/PrevisaoPLD/cpas_ctl_common/scripts/newave.sh 27 $1;

ec=$?

exit $ec
