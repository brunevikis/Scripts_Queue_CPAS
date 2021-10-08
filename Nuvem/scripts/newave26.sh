#!/bin/bash

echo "/home/producao/PrevisaoPLD/cpas_ctl_common/scripts/newave.sh 26";

/home/producao/PrevisaoPLD/cpas_ctl_common/scripts/newave.sh 26 $1;

ec=$?

exit $ec
