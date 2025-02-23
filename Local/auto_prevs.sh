#!/bin/bash
LANG=en_US.utf8
for c in $(ls -1 /home/producao/PrevisaoPLD/enercore_ctl_common/waiting_prevs/); do
  echo $c
  p=$( sed -n 's/^dir=//p' /home/producao/PrevisaoPLD/enercore_ctl_common/waiting_prevs/$c )
  if [ -d "/home/producao/PrevisaoPLD/enercore_ctl_common/auto/$c/" ]; then
    cd /home/producao/PrevisaoPLD/enercore_ctl_common/auto/
    mv "$c/"* "$p"
    rm -r "$c"
    mv "/home/producao/PrevisaoPLD/enercore_ctl_common/waiting_prevs/$c" "/home/producao/PrevisaoPLD/enercore_ctl_common/queue/${c}_$(date +%Y%m%d%H%M%S)"
  fi
done