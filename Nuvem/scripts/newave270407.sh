#!/bin/bash

echo "/home/compass/sacompass/previsaopld/cpas_ctl_common/scripts/newave.sh 270407";

/home/compass/sacompass/previsaopld/cpas_ctl_common/scripts/newave.sh 270407 $1;

ec=$?

exit $ec
