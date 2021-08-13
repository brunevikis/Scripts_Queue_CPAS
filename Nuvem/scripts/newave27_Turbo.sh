#!/bin/bash

echo "/home/compass/sacompass/previsaopld/cpas_ctl_common/scripts/newave.sh 27";

/home/compass/sacompass/previsaopld/cpas_ctl_common/scripts/newave.sh 27 $1;

ec=$?

exit $ec
