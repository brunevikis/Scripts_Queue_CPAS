#!/bin/bash

echo "/home/producao/PrevisaoPLD/enercore_ctl_common/scripts/newave_new.sh 29";

/home/producao/PrevisaoPLD/enercore_ctl_common/scripts/newave_new.sh 29 $1;

ec=$?

exit $ec
