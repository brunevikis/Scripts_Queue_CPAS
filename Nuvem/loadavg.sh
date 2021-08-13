#!/bin/bash

if (( $(echo $(cat /proc/uptime | cut -d' ' -f1) " < 600" | bc) )); then
  exit
fi

#if grep -q $(hostname)$ /home/compass/sacompass/previsaopld/cpas_ctl_common/running/*; then
if grep -q $(hostname)$ /home/compass/queuectl/running/*; then

  arq="/home/compass/sacompass/previsaopld/cpas_ctl_common/loadavg/$(hostname)"
  if [ -f "$arq" ]; then
    #cat $arq >> "/home/compass/sacompass/previsaopld/cpas_ctl_common/loadavg/log/$(hostname)"
    arq="/home/compass/sacompass/previsaopld/cpas_ctl_common/loadavg/log/$(hostname)"
fi
  nmin=$(echo $(nproc)*0.2 | bc)
  echo $nmin
  #while (true); do
  if (( $(echo $(cat /proc/loadavg | cut -f3 -d' ') " < " $nmin | bc) )); then
    TZ=":GMT+3" date +%Y-%m-%d\ %T >> $arq
#    grep -l $(hostname)$ /home/compass/sacompass/previsaopld/cpas_ctl_common/running/* | cut -f8 -d'/' >> $arq
    grep -l $(hostname)$ /home/compass/queuectl/running/* | cut -f8 -d'/' >> $arq
    cat /proc/loadavg >> $arq
  else
    rm "/home/compass/sacompass/previsaopld/cpas_ctl_common/loadavg/$(hostname)"
  fi
  #sleep 60;
  #done
fi
