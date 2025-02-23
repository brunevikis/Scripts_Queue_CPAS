#!/bin/bash

echo "/home/producao/PrevisaoPLD/enercore_ctl_common/scripts/FT/newave.sh 281107";

/home/producao/PrevisaoPLD/enercore_ctl_common/scripts/FT/newave.sh 281107 $1;

ec=$?

exit $ec
