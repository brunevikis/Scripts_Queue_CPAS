#!/bin/bash

echo "/home/compass/sacompass/previsaopld/cpas_ctl_common/scripts/newave.sh 270001";

/home/compass/sacompass/previsaopld/cpas_ctl_common/scripts/newave.sh 270001 $1;

ec=$?

exit $ec
