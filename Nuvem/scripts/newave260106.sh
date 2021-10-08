#!/bin/bash

echo "/home/compass/sacompass/previsaopld/cpas_ctl_common/scripts/newave.sh 260106";

/home/compass/sacompass/previsaopld/cpas_ctl_common/scripts/newave.sh 260106 $1;

ec=$?

exit $ec
