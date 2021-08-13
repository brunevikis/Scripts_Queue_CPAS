#!/bin/bash
Dir_L=$1

if [ -z ${Dir_L} ]; then
   echo "nothing to do"
   exit 1
fi


Dir=$( echo ${Dir_L} | cut -d"/" -f5-45)
Dir_Z="/home/compass/sacompass/previsaopld/"$Dir 

mkdir -p "$Dir_Z"

echo "$Dir_L" > "${Dir_Z}/rsync_L_Z.log" 2>&1 
echo "$Dir_Z" >> "${Dir_Z}/rsync_L_Z.log" 2>&1 


( { mkdir -p "$Dir_Z"; } )

#ssh -p2222 -i /home/compass/.ssh/id_rsa producao@127.0.0.1 "
#    cd $Dir_L
#    for i in \$( ls -p | grep \"/$\" -v ); do
#        AUXLOWER=\`echo \$i | tr [:upper:] [:lower:]\`;
#        if [ ! \"\$i\" == \"\$AUXLOWER\" ]; then
#            mv \$i \$AUXLOWER;
#        fi
#    done
#"
rsync --rsh='ssh -p2222 -i /home/compass/.ssh/id_rsa' --progress -rlDvzr --include-from '/home/compass/sacompass/previsaopld/cpas_ctl_common/arq_entrada.txt' --filter '+ */' --exclude '*' "producao@127.0.0.1:\"${Dir_L}\""/* "${Dir_Z}" >> "${Dir_Z}/rsync_L_Z.log" 2>&1 


echo "$Dir_Z"