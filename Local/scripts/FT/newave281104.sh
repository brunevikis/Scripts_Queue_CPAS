#!/bin/bash

echo "/home/producao/PrevisaoPLD/enercore_ctl_common/scripts/FT/newave.sh 281104";

/home/producao/PrevisaoPLD/enercore_ctl_common/scripts/FT/newave.sh 281104 $1;

ec=$?

exit $ec
