#!/bin/bash

echo "/home/producao/PrevisaoPLD/cpas_ctl_common/scripts/newave2.sh 2506_temp 36";

/home/producao/PrevisaoPLD/cpas_ctl_common/scripts/newave2.sh 2506_temp 40 $1;

ec=$?

exit $ec
