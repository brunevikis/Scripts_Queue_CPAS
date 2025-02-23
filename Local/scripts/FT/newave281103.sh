#!/bin/bash

echo "/home/producao/PrevisaoPLD/enercore_ctl_common/scripts/FT/newave.sh 281103";

/home/producao/PrevisaoPLD/enercore_ctl_common/scripts/FT/newave.sh 281103 $1;

ec=$?

exit $ec
