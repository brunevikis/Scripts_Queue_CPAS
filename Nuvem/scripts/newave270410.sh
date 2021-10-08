#!/bin/bash

echo "/home/compass/sacompass/previsaopld/cpas_ctl_common/scripts/newave.sh 270410";

/home/compass/sacompass/previsaopld/cpas_ctl_common/scripts/newave.sh 270410 $1;

ec=$?

exit $ec
