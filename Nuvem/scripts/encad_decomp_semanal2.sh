#!/bin/bash

LANG=en_US.utf8

comando="/home/compass/sacompass/previsaopld/cpas_ctl_common/scripts/decomp301Viab.sh"

dir=$( pwd )

rid=$( echo "$dir" | rev | cut -d'/' -f2 )
currentREV=$(( ${rid:0:1} ))
currentCase=$( echo "$dir" | rev | cut -d'/' -f1 | rev )
currentRootDir=$( echo "$dir" | rev | cut -d'/' -f3-50 | rev )

echo $INICIO


echo ""
echo "$dir"

if [ $( echo "$currentCase" | grep -e "_0$" | wc -l ) == 1 ]
then

    echo "$comando"
    #$comando

    ec=$? 
    #if [[ $ec != 0 ]]
    #then
    #    exit $ec;
    #fi
    rvNextFolder=""
    if [ -d ../../REV"$(( $currentREV + 1 ))" ]
    then 
        rvNextFolder="$currentRootDir"/REV"$(( $currentREV + 1 ))"    
    elif [ -d ../../RV"$(( $currentREV + 1 ))" ]
    then
        rvNextFolder="$currentRootDir"/RV"$(( $currentREV + 1 ))"
    fi

    if [[ -n "$rvNextFolder" ]]
    then

        currentCaseName=${currentCase::${#currentCase}-2}
    
        for nextF in $( find "$rvNextFolder" -type d -name "${currentCaseName}_*" )
        do            
            echo /home/compass/sacompass/previsaopld/cpas_ctl_common/scripts/buscaEarm_dc_dc.sh "$dir" "$nextF"            
            /home/compass/sacompass/previsaopld/cpas_ctl_common/scripts/buscaEarm_dc_dc.sh "$dir" "$nextF"            

            echo "AGENDAR NOVA EXECUCAO"
            if [ $( echo "$nextF" | grep -e "_0$" | wc -l ) == 1 ]            
            then
                 dt=$(date +%Y%m%d%H%M%S)          
                 ord=$(( 30 ))
                 usr="encad"
                 fn="/home/compass/sacompass/previsaopld/cpas_ctl_common/queue/encadeado_decomp_semanal_${dt}"
                 cmd="/home/compass/sacompass/previsaopld/cpas_ctl_common/scripts/encad_decomp_semanal.sh"
                 
                 printf -v newComm "%s\n" "ord=${ord}" "usr=${usr}" "dir=${nextF}" "cmd=${cmd}" "ign=False" "cluster="
                 
                 echo ""
                 echo "$newComm" #> ${fn}
                 echo "$newComm" > ${fn}

            else
                 dt=$(date +%Y%m%d%H%M%S)
                 ord=$(( 31 ))
                 usr="encad"
                 fn="/home/compass/sacompass/previsaopld/cpas_ctl_common/queue/encadeado_decomp_semanal_${dt}"
                 cmd="$comando"
                 
                 printf -v newComm "%s\n" "ord=${ord}" "usr=${usr}" "dir=${nextF}" "cmd=${cmd}" "ign=False" "cluster="
                 
                 echo ""
                 echo "$newComm" #> ${fn}
                 echo "$newComm" > ${fn}
            fi
        done 
    fi
fi

exit 0;
