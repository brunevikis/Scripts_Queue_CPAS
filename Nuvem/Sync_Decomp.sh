#!/bin/bash
Dir_Atual=$(pwd)
Dir=$(pwd | cut -d"/" -f6-45)
Dir_L="/home/producao/PrevisaoPLD/"$Dir 

echo "$Dir_Atual"
echo "$Dir_L"

( { ssh -i /home/compass/.ssh/id_rsa producao@127.0.0.1 -p 2222 "mkdir -p \"$Dir_L\"";})



rsync --rsh='ssh -p2222 -i /home/compass/.ssh/id_rsa' --progress -avzr --include-from '/home/compass/sacompass/previsaopld/cpas_ctl_common/arq_DC.txt' --exclude '*' "$Dir_Atual"/* "producao@127.0.0.1:\"$Dir_L\""
