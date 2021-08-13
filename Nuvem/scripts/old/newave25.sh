#!/bin/bash

echo "/home/producao/PrevisaoPLD/cpas_ctl_common/scripts/newave.sh 25";

/home/producao/PrevisaoPLD/cpas_ctl_common/scripts/newave.sh 25 $1;

ec=$?

exit $ec
