#!/bin/bash

LANG=en_US.utf8

anomes=$1

if [ -z $anomes ]
then
	anomes=$( ls -1 | head -n1 )    
fi

ano=${anomes:0:4}
mes=${anomes:4:2}

anoN=""
mesN=""

outputPath=""

dir=$( pwd )

replaceEarmDger()
{

unset _va

while read -r _line
do
    IFS=';' read -r -a array <<< "$_line";

    
    
    #_ree=$( echo ${array[2]} | bc )
    _vFin=$( echo ${array[10]} | tr - 0 | bc -l )

    echo "${array[2]} ${_vFin}"

    _va=( ${_va[@]} $_vFin )
    #volFinRee[$_ree]=$_vFin
    
done <<< "$( unzip -p "$outputPath/csv.zip" dec_oper_ree.csv | grep -E '^ *('${periodofinal}') *; *(\1)\s *' )"

printf -v dgerV "%6.1f " ${_va[@]}

sed '24s/\(^.\{20\}\).*/\1'"$dgerV"'/' dger.dat  -i
sed '22s/\(^.\{21\}\).\{4\}\(.*\)/\1   0\2/' dger.dat -i

}

echo $INICIO


echo $ano
echo $mes

if [ -d $ano$mes ]
then
    
    echo "ok"
    
    cd $ano$mes

    echo $( pwd )

    echo /opt/aplicacoes/cpas_ctl/scripts/newave22
    /opt/aplicacoes/cpas_ctl/scripts/newave22

    ec=$?

    wait

    if [[ $ec == 1 ]]
    then 
       exit 1;
    fi

    #proxima iteração
    
    mesN=$(( 10#$mes + 1 ))
    anoN=$ano
    
    if [[ "$mesN" == "13" ]]
    then
        mesN="01"
        anoN=$(( $anoN + 1 ))
    fi

    printf -v mesN "%02i" $mesN

        if [ -d ../$anoN$mesN ]
        then
            cd ../$anoN$mesN
            echo $( pwd )
            replaceEarmDger 
        fi

        #agenda nova execucao

        echo "AGENDAR NOVA EXECUCAO"
        echo "$0 $anoN$mesN"

        dt=$(date +%Y%m%d%H%M%S)
        ord=$(( 20 + 10#$mesN ))
        usr="encad"
        fn="/home/producao/PrevisaoPLD/cpas_ctl_common/queue/encad_newave_${anoN}${mesN}_${dt}"
        cmd="$0 ${anoN}${mesN}"

        printf -v newComm "%s\n" "ord=${ord}" "usr=${usr}" "dir=${dir}" "cmd=${cmd}" "ign=False" "cluster="
        
        echo ""
        echo "$newComm" #> ${fn}
        echo "$newComm" > ${fn}
    fi
fi


exit 0;
