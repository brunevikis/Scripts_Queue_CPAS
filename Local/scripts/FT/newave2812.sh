#!/bin/bash

echo "/home/producao/PrevisaoPLD/enercore_ctl_common/scripts/FT/newave.sh 2812";

/home/producao/PrevisaoPLD/enercore_ctl_common/scripts/FT/newave.sh 2812 $1;

ec=$?

exit $ec
