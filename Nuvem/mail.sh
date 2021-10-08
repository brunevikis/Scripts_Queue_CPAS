#!/bin/bash

c=$( find /home/compass/sacompass/previsaopld/cpas_ctl_common/loadavg/ -maxdepth 1 -type f -cmin -5 -exec basename {} \;)

echo ${c[@]}
for i in $c; do
  mail -A cpas -s "Load avg $i" pedro.modesto@enercore.com.br,bruno.araujo@enercore.com.br,natalia.biondo@enercore.com.br < "/home/compass/sacompass/previsaopld/cpas_ctl_common/loadavg/$i"
done




