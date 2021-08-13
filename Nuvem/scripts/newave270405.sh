#!/bin/bash

echo "/home/compass/sacompass/previsaopld/cpas_ctl_common/scripts/newave.sh 270405";

/home/compass/sacompass/previsaopld/cpas_ctl_common/scripts/newave.sh 270405 $1;

ec=$?

exit $ec
