#!/bin/bash

LANG=en_US.utf8
export LC_ALL=C.UTF-8

if [ -f /home/producao/PrevisaoPLD/enercore_ctl_common/scripts/functions.sh ]; then source /home/producao/PrevisaoPLD/enercore_ctl_common/scripts/functions.sh; 
else echo "Saindo" exit 1; fi;
#---------------------------------
agendaDC(){
    echo "AGENDAR DC - $1"
    dt=$(date +%Y%m%d%H%M%S)
    ord=$(( 20 + 10#$mesN ))
    usr="encad"
    fn="/home/producao/PrevisaoPLD/enercore_ctl_common/queue/encadeado_DC${ano}${mes}_${dt}"
    cmd="/home/producao/PrevisaoPLD/enercore_ctl_common/scripts/FT/decomp31.17Viab.sh"
    
    printf -v newComm "%s\n" "ord=${ord}" "usr=${usr}" "dir=$1" "cmd=${cmd}" "ign=False" "cluster="
    
    echo ""
    echo "$newComm" > ${fn}
}


agendaDCGNL(){
    echo "AGENDAR DCGNL - $1"
    dt=$(date +%Y%m%d%H%M%S%3N)
    ord=$(( 19 ))
    usr="encad"
    fn="/home/producao/PrevisaoPLD/enercore_ctl_common/queue/encadeado_DC${ano}${mes}_${dt}"
    cmd="/home/producao/PrevisaoPLD/enercore_ctl_common/scripts/FT/GNL/DADGNL_decomp31.17Viab_earDC_regrasANA_cortesPOS_NW2815.sh"
    
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
    fn="/home/producao/PrevisaoPLD/enercore_ctl_common/queue/encadeado_NW${anoN}${mesN}_${dt}"
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
    done <<< "$( tail -n+4 ree.dat | grep '^\s*\(999\|FICT\)' -v )"
}
#---------------------------------
colectEARMFinal(){

    unset earmf
    unset earmfp
    unset earmmax 
    

    for ree in ${rees[*]}; do

        printf -v strree "%03i" $ree
    
        earm=$( grep "^\s*MEDIA" earmf${strree}.out | head -n1 | tr - 0 );
        earmp=$( grep "^\s*MEDIA" earmfp${strree}.out | head -n1 | tr - 0 );
                
        IFS=' ' read -r -a array <<< "$earm";
        IFS=' ' read -r -a arrayp <<< "$earmp";
    
        earmf[$ree]=${array[$(( 10#$mes ))]};
        earmfp[$ree]=${arrayp[$(( 10#$mes ))]};    
        if [ "${earmfp[$ree]}" = "0" ]; then

            earmmax[$ree]=0
        else
            earmmax[$ree]=$( echo " scale=2 ; (${earmf[$ree]}/${earmfp[$ree]})*100 " | bc -l)
        fi
    done
}
#---------------------------------
colectEARMFinalMercado(){
    for sis in {1..4}; do    

        printf -v strsis "%03i" $sis
    
        earm=$( grep "^\s*MEDIA" earmfm${strsis}.out | head -n1 | tr - 0 );
        earmp=$( grep "^\s*MEDIA" earmfpm${strsis}.out | head -n1 | tr - 0 );
    
        IFS=' ' read -r -a array <<< "$earm";
        IFS=' ' read -r -a arrayp <<< "$earmp";
    
        earmfm[$sis]=${array[$(( 10#$mes ))]};
        earmfpm[$sis]=${arrayp[$(( 10#$mes ))]};
        earmmaxm[$sis]=$( echo " scale=3 ; (${earmfm[$sis]}/${earmfpm[$sis]})*100 " | bc -l)
    done
}
#---------------------------------
colectEARMInicial(){
    unset earmi
    unset earmip    
    
    ln=$( grep "ENERGIA ARMAZENADA INICIAL" pmo.dat -n | cut -d':' -f1 )
      
    IFS=' ' read -r -a arrayp <<< $( tail pmo.dat -n+$ln | head -n5 | tail -n1 | tr - 0 )
    IFS=' ' read -r -a array <<< $( tail pmo.dat -n+$ln | head -n4 | tail -n1 | tr - 0 )
    
    for reeI in ${!rees[*]}; do

        ree=${rees[$reeI]}
        
        earmi[$ree]=${array[$reeI]};
        earmip[$ree]=${arrayp[$(( $reeI * 2 ))]};    
    done
}
#---------------------------------
setEARMNewaveNext(){

    ln=$( grep "ENERGIA ARMAZENADA INICIAL" "./$2/pmo.dat" -n | cut -d':' -f1 )
    IFS=' ' read -r -a array <<< $( tail ./$2/pmo.dat -n+$ln | head -n4 | tail -n1 | tr - 0 )
    
    earmNm=( "" 0 0 0 0)  
    for reeI in ${!rees[*]}; do

        ree=${rees[$reeI]}
        earmNm[${reeSis[$ree]}]=$( echo "${earmNm[${reeSis[$ree]}]} + ${array[$reeI]} " | bc -l )    
    done
    
    echo earmNm "${earmNm[@]}";
    earmNpm[1]=$( echo "scale=4 ; (${earmNm[1]}/${earmmaxm[1]})*100" | bc -l )
    earmNpm[2]=$( echo "scale=4 ; (${earmNm[2]}/${earmmaxm[2]})*100" | bc -l )
    earmNpm[3]=$( echo "scale=4 ; (${earmNm[3]}/${earmmaxm[3]})*100" | bc -l )
    earmNpm[4]=$( echo "scale=4 ; (${earmNm[4]}/${earmmaxm[4]})*100" | bc -l )
    
    echo earmNpm "${earmNpm[@]}"
    echo earmfpm "${earmfpm[@]}"
    echo earmfp "${earmfp[@]}"
    
    for sis in {1..4}; do

        volumePO=${earmNpm[$sis]} #
        volumeFinalMercado=${earmfpm[$sis]}
        for ree in ${rees[@]}; do

            if [[ ${reeSis[$ree]} -eq $sis ]]; then      

                volumeFinalRee=${earmfp[$ree]}
                if [[ $sis -eq 2 ]]; then

                    earmNp[$ree]=$volumePO
                elif [ $( echo "$volumeFinalRee == 0 " | bc -l ) = "1" ]; then

                    earmNp[$ree]=0
                elif [ $( echo "$volumePO < $volumeFinalMercado " | bc -l ) = "1" ]; then

                    earmNp[$ree]=$( echo "scale=3 ; $volumePO * ( $volumeFinalRee / $volumeFinalMercado )" | bc -l )
                else
                    earmNp[$ree]=$( echo "scale=3 ; ( ( $volumePO - 100 ) * ( ( $volumeFinalRee - 100 ) / ( $volumeFinalMercado - 100.1 ) ) ) + 100" | bc -l )
                fi
            fi
        done
    done
    echo earmNp "${earmNp[@]}"
    
    unset _va
    
    for reeI in ${!rees[*]}; do
        _vI=$( echo ${earmNp[${rees[$reeI]}]} | tr - 0 | bc -l )
        if float_cond "$_vI > 100"
        then
            _vI=100.0
        fi
        _va=( ${_va[@]} $_vI )
    done

    
    printf -v dgerV "%6.1f " ${_va[@]}
    echo earmDger "$dgerV"
    
    sed '24s/\(^.\{20\}\).*/\1'"$dgerV"'/' "./$2/dger.dat" -i
    sed '22s/\(^.\{21\}\).\{4\}\(.*\)/\1   0\2/' "./$2/dger.dat" -i
}
#---------------------------------
setEARMNewdesp(){
    unset _va

    for reeI in ${!rees[*]}; do

        _vI=$( echo ${earmi[${rees[$reeI]}]} | tr - 0 | bc -l )
        _va=( ${_va[@]} $_vI )
    done
    
    # printf " %10.3f" ${_va[@]}    
    printf -v dgernwd " %10.3f" ${_va[@]}    


    sed '6s/.*/'"$dgernwd"'/' dger.nwd -i
}

#---------------------------------COMEÇO DO SCRIPT-----------------------------
echo "Começou o Script" 
anomes=$1
nwDates=$( ls | grep -E '^20[0-9]{4}' | sort -n )
if [ -z $anomes ]; then
    anomes=$( echo "$nwDates" | head -n1 )
    first=1
fi
it=0
anoN=""
mesN=""
ano=${anomes:0:4}
mes=${anomes:4:2}

if [ -d $ano$mes ]; then
    cd $ano$mes
    echo "-----------[ Convertendo todos os arquivos para minusculas ]-----------";
    for i in $( ls -p | grep "/$ " -v ); do
        AUXLOWER=`echo $i | tr [:upper:] [:lower:]`;
        if [ ! "$i" == "$AUXLOWER" ]; then
            echo -n "Convertendo $i para $AUXLOWER ... ";
            mv $i $AUXLOWER;
            if [ -f $AUXLOWER ]; then
                echo "ok";
            else
                echo "erro";
            fi
        fi
    done
    /usr/bin/dos2unix *
    if [[ "$mes" == "01" || "$mes" == "05" || "$mes" == "09" ]]; then
      sed -i '99s/\(^.\{23\}\).\{2\}\(.*\)/\1 0\2/' "./dger.dat"
    else
      sed -i '99s/\(^.\{23\}\).\{2\}\(.*\)/\1 1\2/' "./dger.dat"
      sed -i  '9s/\(^.\{23\}\).\{2\}\(.*\)/\1 0\2/' "./dger.dat"
      sed -i.bkp '/^POS/d' sistema.dat
      sed -i.bkp '/^POS/d' c_adic.dat
    fi
    #Altera Adterm
    echo "/usr/bin/dotnet /home/producao/PrevisaoPLD/shared/price_tools/inviab/bin/Debug/netcoreapp3.1/TrataInviab.dll adterm "
    /usr/bin/dotnet /home/producao/PrevisaoPLD/shared/price_tools/inviab/bin/Debug/netcoreapp3.1/TrataInviab.dll "adterm"
    echo $( pwd )
    ree="$(date -d "$(pwd|grep -o '[^/]*$')01 +12months" "+%m %Y")"
    #sed -i "s/\(  .*[0-4]\) *$/\\1  $ree/;/FICT/d;/ 999/a FICT. INDIVIDUAL.   0000" ree.dat
    if [ -z $first ]; then
        sed '22s/\(^.\{21\}\).\{4\}\(.*\)/\1   1\2/' dger.dat -i
    fi
    if [ ! -f "cortes.dat" ]; then
        echo /home/producao/PrevisaoPLD/enercore_ctl_common/scripts/FT/newave2815.sh 1
        /home/producao/PrevisaoPLD/enercore_ctl_common/scripts/FT/newave2815.sh 1
        ec=$?
        if [[ $ec == 1 ]]; then 
            exit 1;
        fi
    else
        echo  "Cortes já existente"
    fi
    if [ -f "cortes.dat" ]; then
        echo /home/producao/PrevisaoPLD/enercore_ctl_common/scripts/FT/nwlistop2815.sh
        /home/producao/PrevisaoPLD/enercore_ctl_common/scripts/FT/nwlistop2815.sh
        ec=$?
        if [[ $ec != 0 ]]; then
            exit $ec;
        fi
        #lerRees
        #colectEARMFinal
        #colectEARMFinalMercado
        #colectEARMInicial
        #setEARMNewdesp
       if [[ "$mes" == "01" ]]; then
         cp  cortes-060.dat "../${ano}02/cortes-pos.dat"
         cp  cortes-060.dat "../${ano}03/cortes-pos.dat"
         cp  cortes-060.dat "../${ano}04/cortes-pos.dat"
         cp  cortesh.dat "../${ano}02/cortesh-pos.dat"
         cp  cortesh.dat "../${ano}03/cortesh-pos.dat"
         cp  cortesh.dat "../${ano}04/cortesh-pos.dat"
       fi
       if [[ "$mes" == "05" ]]; then
         cp  cortes-060.dat "../${ano}06/cortes-pos.dat"
         cp  cortes-060.dat "../${ano}07/cortes-pos.dat"
         cp  cortes-060.dat "../${ano}08/cortes-pos.dat"
         cp  cortesh.dat "../${ano}06/cortesh-pos.dat"
         cp  cortesh.dat "../${ano}07/cortesh-pos.dat"
         cp  cortesh.dat "../${ano}08/cortesh-pos.dat"
       fi
       if [[ "$mes" == "09" ]]; then
         cp  cortes-060.dat "../${ano}10/cortes-pos.dat"
         cp  cortes-060.dat "../${ano}11/cortes-pos.dat"
         cp  cortes-060.dat "../${ano}12/cortes-pos.dat"
         cp  cortesh.dat "../${ano}10/cortesh-pos.dat"
         cp  cortesh.dat "../${ano}11/cortesh-pos.dat"
         cp  cortesh.dat "../${ano}12/cortesh-pos.dat"
       fi
        cd ..
        dcPaths=$( ls | grep -E '^20[0-9]{4}' -v )
        for dc in $dcPaths ; do
            if [ -d "$dc/$ano$mes" ]; then
                gnl=$(echo $dc | grep DCGNL)
                if [ ! "$gnl" == "" ]; then
                    agendaDCGNL "$( pwd )/$dc/$ano$mes"
                    sleep 2
                    echo ""
                fi
            fi
        done
       #mesN=$(( 10#$mes + 1 ))
       #anoN=$ano
       #if [[ "$mesN" == "13" ]]; then
       #     mesN="01"
       #     anoN=$(( $anoN + 1 ))
       #fi
       #printf -v mesN "%02i" $mesN
       #if [ -d $anoN$mesN ]; then    
       #  echo setEARMNewaveNext "$ano$mes" "$anoN$mesN"
       #  setEARMNewaveNext "$ano$mes" "$anoN$mesN"
       #fi        
   else    
        echo  "Erro na execução do newave. Cortes não encontrado"
        exit 1
    fi
fi
