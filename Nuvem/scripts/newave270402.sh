#!/bin/bash

echo "/home/compass/sacompass/previsaopld/cpas_ctl_common/scripts/newave.sh 270402";

/home/compass/sacompass/previsaopld/cpas_ctl_common/scripts/newave.sh 270402 $1;

ec=$?

exit $ec
