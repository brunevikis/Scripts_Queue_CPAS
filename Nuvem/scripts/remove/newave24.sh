#!/bin/bash

echo "/home/producao/PrevisaoPLD/cpas_ctl_common/scripts/newave2.sh 24 36";

/home/producao/PrevisaoPLD/cpas_ctl_common/scripts/newave2.sh 24 40 $1;

ec=$?

exit $ec
