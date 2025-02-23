#!/bin/bash

echo "/home/producao/PrevisaoPLD/enercore_ctl_common/scripts/FT/newave_new.sh 29";

/home/producao/PrevisaoPLD/enercore_ctl_common/scripts/FT/newave_new.sh 29 $1;

ec=$?

exit $ec
