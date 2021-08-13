#!/bin/bash

LANG=en_US.utf8

agendaDC(){
    echo "AGENDAR DC - $1"
    dt=$(date +%Y%m%d%H%M%S)
    ord=$(( 23 ))
    usr="encad"
    fn="/home/compass/sacompass/previsaopld/cpas_ctl_common/queue/encadeado_DC${anomes}_${dt}"
    cmd="/home/compass/sacompass/previsaopld/cpas_ctl_common/scripts/decomp301Viab.sh"
    
    printf -v newComm "%s\n" "ord=${ord}" "usr=${usr}" "dir=$1" "cmd=${cmd}" "ign=False" "cluster="
    
    echo ""
    echo "$newComm" > ${fn}
}

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
anomes=$1




cd $anomes

dcPaths=$(ls -d1 [0-9]*)


        for dc in $dcPaths ; do
                agendaDC "$( pwd )/$dc"
                sleep 2
                echo ""
        done


