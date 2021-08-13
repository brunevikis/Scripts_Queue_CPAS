#!/bin/bash

echo "/home/compass/sacompass/previsaopld/cpas_ctl_common/scripts/newave.sh 270406";

/home/compass/sacompass/previsaopld/cpas_ctl_common/scripts/newave.sh 270406 $1;

ec=$?

exit $ec
