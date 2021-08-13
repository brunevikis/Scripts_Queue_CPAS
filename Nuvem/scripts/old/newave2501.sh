#!/bin/bash

echo "/home/producao/PrevisaoPLD/cpas_ctl_common/scripts/newave.sh $1";

/home/producao/PrevisaoPLD/cpas_ctl_common/scripts/newave.sh 2501 $1;

ec=$?

exit $ec
