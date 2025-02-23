#!/bin/bash

echo "/home/producao/PrevisaoPLD/enercore_ctl_common/scripts/FT/newave.sh 2815";

/home/producao/PrevisaoPLD/enercore_ctl_common/scripts/FT/newave.sh 2815 $1;

ec=$?

exit $ec
