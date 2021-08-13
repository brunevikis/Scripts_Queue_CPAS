#!/bin/bash
Dir_Z=$(pwd)
Dir=$(pwd | cut -d"/" -f6-45)
Dir_L="/home/producao/PrevisaoPLD/"$Dir 

echo "$Dir_Z" > "${Dir_Z}/rsync_Z_L.log" 2>&1 
echo "$Dir_L" >> "${Dir_Z}/rsync_Z_L.log" 2>&1 

( { ssh -i /home/compass/.ssh/id_rsa producao@127.0.0.1 -p 2222 "mkdir -p \"$Dir_L\"" ; } )

(find -type f -iname cortes.dat | cut -d'/' -f2- | xargs -I{} bash -c "[ -f \"${Dir_Z}/{}\" ] && { ssh -i /home/compass/.ssh/id_rsa producao@127.0.0.1 -p 2222 \"[ ! -f \\\"${Dir_L}/{}\\\" ] && echo \\\"${Dir_Z}/{}\\\" > \\\"${Dir_L}/{}\\\"\"; }")



#if [ -f "${Dir_Z}/cortes.dat" ]
#then
#    ( { ssh -i /home/compass/.ssh/id_rsa producao@127.0.0.1 -p 2222 "echo \"${Dir_Z}/cortes.dat\" > \"${Dir_L}/cortes.dat\""; } )
#fi

rsync --rsh='ssh -p2222 -i /home/compass/.ssh/id_rsa' --progress -avzr --include-from '/home/compass/sacompass/previsaopld/cpas_ctl_common/arq_saida.txt' --filter '+ */' --exclude '*' "$Dir_Z"/* "producao@127.0.0.1:\"$Dir_L\"" >> "${Dir_Z}/rsync_Z_L.log" 2>&1 
