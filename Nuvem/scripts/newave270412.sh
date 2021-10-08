#!/bin/bash

echo "/home/compass/sacompass/previsaopld/cpas_ctl_common/scripts/newave.sh 270412";

/home/compass/sacompass/previsaopld/cpas_ctl_common/scripts/newave.sh 270412 $1;

ec=$?

exit $ec
