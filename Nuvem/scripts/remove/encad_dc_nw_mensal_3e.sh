#!/bin/bash

LANG=en_US.utf8

if [ -f /home/producao/PrevisaoPLD/cpas_ctl_common/scripts/functions.sh ]; then source /home/producao/PrevisaoPLD/cpas_ctl_common/scripts/functions.sh; 
else exit 1; fi;
#---------------------------------
agendaDC(){
    echo "AGENDAR DC - $1"
    dt=$(date +%Y%m%d%H%M%S)
    ord=$(( 20 + 10#$mesN ))
    usr="encad"
    fn="/home/producao/PrevisaoPLD/cpas_ctl_common/queue/encadeado_DC${ano}${mes}_${dt}"
    cmd="/home/producao/PrevisaoPLD/cpas_ctl_common/scripts/decomp29Viab.sh"
    
    printf -v newComm "%s\n" "ord=${ord}" "usr=${usr}" "dir=$1" "cmd=${cmd}" "ign=False" "cluster="
    
    echo ""
    echo "$newComm" > ${fn}
}
#---------------------------------
agendaProximaIteracao(){
    echo "AGENDAR NW - $1"
    dt=$(date +%Y%m%d%H%M%S)
    ord=$(( 20 + 10#$mesN ))
    usr="encad"
    fn="/home/producao/PrevisaoPLD/cpas_ctl_common/queue/encadeado_NW${anoN}${mesN}_${dt}"
    cmd="$0 $1"

    printf -v newComm "%s\n" "ord=${ord}" "usr=${usr}" "dir=$( pwd )" "cmd=${cmd}" "ign=False" "cluster="

    echo ""
    echo "$newComm" > ${fn}
}
#---------------------------------
lerRees(){
    unset rees
    unset reeSis
    
    reei=0
    while read -r _line; do

        IFS=' ' read -r -a _rees <<< "$_line";
        ree=${_rees[0]}
        sis=${_rees[2]}
        
        rees[$reei]=$ree
        reeSis[$ree]=$sis
        
        reei=$(( $reei + 1 ))    
    done <<< "$( tail -n+4 ree.dat | grep '^\s*999' -v )"
    

    #  echo ${rees[@]}
    #  echo ${reeSis[@]}

}
#--------------------------------- colectEARMFinal from consulta.nwd
colectEARMFinal(){ #  from consulta.nwd

    unset earmf
    unset earmfp
    unset earmmax 
    
    unset earmfm
    unset earmfpm
    unset earmmaxm
    
    earmfm=( "" 0 0 0 0) 
    earmfpm=( "" 0 0 0 0) 
    earmmaxm=( "" 0 0 0 0)
    
    ln=$( grep "^\s*EARMF" consulta.nwd | tr EARMF ' ')
    lnM=$( grep "^\s*EARMx" consulta.nwd | tr EARMx ' ')
        
    IFS=' ' read -r -a arrayM <<< $lnM
    IFS=' ' read -r -a array <<< $ln

    for reeI in ${!rees[*]}; do

        ree=${rees[$reeI]}
        
        earmf[$ree]=${array[$reeI]};
        earmmax[$ree]=${arrayM[$reeI]};                 
        earmfp[$ree]=0.0;
        
        if float_cond "${earmmax[$ree]} > 0" 
		then
          earmfp[$ree]=$( echo " scale=5 ; (${earmf[$ree]}/${earmmax[$ree]})*100.00 " | bc -l )
        fi
        
		#echo "${earmfm[${reeSis[$ree]}]} + ${array[$reeI]} "
		
        earmfm[${reeSis[$ree]}]=$( echo "${earmfm[${reeSis[$ree]}]} + ${array[$reeI]} " | bc -l )  
        earmmaxm[${reeSis[$ree]}]=$( echo "${earmmaxm[${reeSis[$ree]}]} + ${arrayM[$reeI]} " | bc -l )
        
    done   
    
    for sis in {1..4}; do
      earmfpm[$sis]=$( echo " scale=5 ; (${earmfm[$sis]}/${earmmaxm[$sis]})*100 " | bc -l)  
    done
	
	echo {earmf[@]}    ${earmf[@]}
    echo {earmfp[@]}   ${earmfp[@]}
    echo {earmmax[@]}  ${earmmax[@]}
    echo  ""             
    echo {earmfm[@]}   ${earmfm[@]}
    echo {earmfpm[@]}  ${earmfpm[@]}
    echo {earmmaxm[@]} ${earmmaxm[@]}
	
}
#---------------------------------
colectEARMInicial(){ #  from pmo.dat
    unset earmi
    unset earmip    
    
    unset earmim
    unset earmipm
    
    earmim=( "" 0 0 0 0)
    earmipm=( "" 0 0 0 0)   
    
    ln=$( grep "ENERGIA ARMAZENADA INICIAL" pmo.dat -n | cut -d':' -f1 )
      
    IFS=' ' read -r -a arrayp <<< $( tail pmo.dat -n+$ln | head -n5 | tail -n1 | tr - 0 )
    IFS=' ' read -r -a array <<< $( tail pmo.dat -n+$ln | head -n4 | tail -n1 | tr - 0 )
    
    for reeI in ${!rees[*]}; do

        ree=${rees[$reeI]}
        
        earmi[$ree]=${array[$reeI]};
        earmip[$ree]=${arrayp[$(( $reeI * 2 ))]};
        
        earmim[${reeSis[$ree]}]=$( echo "${earmim[${reeSis[$ree]}]} + ${array[$reeI]} " | bc -l )       
    done
    
    for sis in {1..4}; do
      earmipm[$sis]=$( echo " scale=2 ; (${earmim[$sis]}/${earmmaxm[$sis]})*100 " | bc -l)  
    done
    

    #echo ${earmi[@]}
    #echo ${earmip[@]}
}
#---------------------------------
colectEARMInicialNext(){ #  from pmo.dat
    unset earmiNext
    unset earmipNext  
    unset earmmaxNext
    
    unset earmiNextm
    unset earmipNextm  
    unset earmmaxNextm
    
    earmiNextm=( "" 0 0 0 0) 
    earmipNextm=( "" 0 0 0 0) 
    earmmaxNextm=( "" 0 0 0 0)
    
    ln=$( grep "ENERGIA ARMAZENADA INICIAL" ./$2/pmo.dat -n | cut -d':' -f1 )
      
    IFS=' ' read -r -a arrayp <<< $( tail ./$2/pmo.dat -n+$ln | head -n5 | tail -n1 | tr - 0 )
    IFS=' ' read -r -a array <<< $( tail ./$2/pmo.dat -n+$ln | head -n4 | tail -n1 | tr - 0 )
    
    for reeI in ${!rees[*]}; do

        ree=${rees[$reeI]}

        earmiNext[$ree]=${array[$reeI]};
        earmipNext[$ree]=${arrayp[$(( $reeI * 2 ))]};  

        if [ "${earmipNext[$ree]}" = "0" ]; then      
                earmmaxNext[$ree]=0
        else
            earmmaxNext[$ree]=$( echo " scale=5 ; (${earmiNext[$ree]}/${earmipNext[$ree]})*100 " | bc -l)
        fi  

        earmiNextm[${reeSis[$ree]}]=$( echo "${earmiNextm[${reeSis[$ree]}]} + ${array[$reeI]} " | bc -l )
        earmmaxNextm[${reeSis[$ree]}]=$( echo "${earmmaxNextm[${reeSis[$ree]}]} + ${earmmaxNext[$ree]} " | bc -l )
    done
    
    for sis in {1..4}; do
      earmipNextm[$sis]=$( echo " scale=5 ; (${earmiNextm[$sis]}/${earmmaxNextm[$sis]})*100 " | bc -l)  
    done
        
	echo {earmiNext[@]}    ${earmiNext[@]}
    echo {earmipNext[@]}   ${earmipNext[@]}
    echo {earmmaxNext[@]}  ${earmmaxNext[@]}
    echo  ""             
    echo {earmiNextm[@]}   ${earmiNextm[@]}
    echo {earmipNextm[@]}  ${earmipNextm[@]}
    echo {earmmaxNextm[@]} ${earmmaxNextm[@]}
}
#---------------------------------
setEARMNewdespNext(){    
    for sis in {1..4}; do

        volumePO=${earmipNextm[$sis]} 
        volumeFinalMercado=${earmfpm[$sis]}
		
		echo volumePO=${earmipNextm[$sis]} 
        echo volumeFinalMercado=${earmfpm[$sis]}
		
        for ree in ${rees[@]}; do

            if [[ ${reeSis[$ree]} -eq $sis ]]; then      

                volumeFinalRee=${earmfp[$ree]}
                if [[ $sis -eq 2 ]]; then

                    earmNp[$ree]=$volumePO
                elif [ $( echo "$volumeFinalRee == 0 " | bc -l ) = "1" ]; then

                    earmNp[$ree]=0
                elif [ $( echo "$volumePO < $volumeFinalMercado " | bc -l ) = "1" ]; then

                    earmNp[$ree]=$( echo "scale=5 ; $volumePO * ( $volumeFinalRee / $volumeFinalMercado )" | bc -l )
                else
                    earmNp[$ree]=$( echo "scale=5 ; ( ( $volumePO - 100 ) * ( ( $volumeFinalRee - 100 ) / ( $volumeFinalMercado - 100 ) ) ) + 100" | bc -l )
                fi
            fi
        done
    done
    
    unset _va    
    
    for reeI in ${!rees[*]}; do
        _vI=$( echo ${earmNp[${rees[$reeI]}]} | tr - 0 | bc -l )
        if float_cond "$_vI > 99.5"
        then
            _vI=99.5
        fi          
        _vI=$( echo "scale=5 ;  (( $_vI * ${earmmaxNext[${rees[$reeI]}]} ) / 100)" | tr - 0 | bc -l )
                
        _va=( ${_va[@]} $_vI )
    done
    
    # printf " %10.3f" ${_va[@]}    
    printf -v dgernwd " %10.3f" ${_va[@]}    
    echo earmDgerNwd "$dgernwd"
    
    sed '6s/.*/'"$dgernwd"'/' ./$2/dger.nwd -i
}
#---------------------------------COMEÇO DO SCRIPT-----------------------------

anomes=$1

nwDates=$( ls | grep -E '^20[0-9]{4}' | sort -n )


if [ -z $anomes ]; then

    anomes=$( echo "$nwDates" | head -n1 )    
fi


it=0

anoN=""
mesN=""

ano=${anomes:0:4}
mes=${anomes:4:2}

if [ -d $ano$mes ]; then

    cd $ano$mes
    
    echo $( pwd )
    

    if [ ! -f "cortes.dat" ]; then

      unzip -uoj ../PLAN4/*$ano$mes.zip NW$ano$mes/cortes.dat 
      unzip -uoj ../PLAN4/*$ano$mes.zip NW$ano$mes/pmo.dat 
      unzip -uoj ../PLAN4/*$ano$mes.zip NW$ano$mes/forward.dat 
      unzip -uoj ../PLAN4/*$ano$mes.zip NW$ano$mes/forwarh.dat 
      unzip -uoj ../PLAN4/*$ano$mes.zip NW$ano$mes/cortesh.dat
                          
        if [ ! -f "cortes.dat" ]; then

            exit "resultados ainda não disponiveis";
        fi
    else
        echo  "Cortes já existente"
    fi
        
    if [ -f "cortes.dat" ]; then
        
             
        echo /home/producao/PrevisaoPLD/cpas_ctl_common/scripts/nwlistop25.sh
        /home/producao/PrevisaoPLD/cpas_ctl_common/scripts/nwlistop25.sh
        
        ec=$?        
        if [[ $ec != 0 ]]; then
            exit $ec;
        fi
        
        
        lerRees

        
        mesN=$(( 10#$mes + 1 ))
        anoN=$ano
        
        
        if [[ "$mesN" == "13" ]]; then

            mesN="01"
            anoN=$(( $anoN + 1 ))
        fi
        printf -v mesN "%02i" $mesN
             
        echo /home/producao/PrevisaoPLD/cpas_ctl_common/scripts/newdesp25.sh
        /home/producao/PrevisaoPLD/cpas_ctl_common/scripts/newdesp25.sh
        
        colectEARMFinal
        colectEARMInicial
        
        cd ..
        
        dcPaths=$( ls | grep -E '^20[0-9]{4}' -v )
        
        for dc in $dcPaths ; do

            if [ -d "$dc/$ano$mes" ]; then

                agendaDC "$( pwd )/$dc/$ano$mes"
                sleep 2
                echo ""
            fi
        done        
        
        
        
        if [ -d $anoN$mesN ]; then    
            #agenda proximomes
            colectEARMInicialNext  "$ano$mes" "$anoN$mesN"
            setEARMNewdespNext "$ano$mes" "$anoN$mesN"
            agendaProximaIteracao "$anoN$mesN"
        fi        
    else    
        echo  "Erro na execução do newave. Cortes não encontrado"
    exit 1
    fi
fi
