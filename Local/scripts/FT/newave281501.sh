#!/bin/bash

echo "/home/producao/PrevisaoPLD/enercore_ctl_common/scripts/FT/newave.sh 281501";

/home/producao/PrevisaoPLD/enercore_ctl_common/scripts/FT/newave.sh 281501 $1;

ec=$?

exit $ec
