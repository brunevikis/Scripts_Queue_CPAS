#!/bin/bash

echo "/home/compass/sacompass/previsaopld/cpas_ctl_common/scripts/newave.sh 270002";

/home/compass/sacompass/previsaopld/cpas_ctl_common/scripts/newave.sh 270002 $1;

ec=$?

exit $ec
