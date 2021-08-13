#!/bin/bash

LANG=en_US.utf8



periodofinal=1

numPeriodos()
{
arqNameO=$( find "$outputPath" -maxdepth 1 -iname caso.dat -exec head -n 1 {} ';' | tr [:upper:] [:lower:]);

vazLn=$( grep "^& VAZOES" "$outputPath/dadger.$arqNameO" -n | cut -f1 -d":" )

numSemL=$( sed "$(( $vazLn + 7))"'!d' "$outputPath/dadger.$arqNameO" )
dias2MesL=$( sed "$(( $vazLn + 8))"'!d' "$outputPath/dadger.$arqNameO")

numSem=${numSemL:39:2}
dias2Mes=${dias2MesL:39:2}

if [ $numSem != 0 ]
then	
    if [ $dias2Mes == 0 ]
    then
        periodofinal=$numSem
    else
        periodofinal=$(( $numSem - 1 ))
    fi
else
    periodofinal=1
fi

#echo $periodofinal

}


anomes=$1
DC_Earm=$2

if [ -z $anomes ]
then
	anomes=$( ls -1 | head -n1 )    
fi

if [ -z $DC_Earm ]
then
	DC_Earm="DC_Earm"  
fi

ano=${anomes:0:4}
mes=${anomes:4:2}

anoN=""
mesN=""

outputPath=""

dir=$( pwd )






replaceUH()
{

arqName=$( find . -maxdepth 1 -iname caso.dat -exec head -n 1 {} ';' | tr [:upper:] [:lower:]);

while read -r _line
do
    IFS=';' read -r -a array <<< "$_line";
    
    _uh=$( echo ${array[4]} | bc )
    _vFin=$( echo ${array[11]} | tr - 0 | bc -l )
    volFin[$_uh]=$_vFin
    
done <<< "$( unzip -p "$outputPath/csv.zip" dec_oper_usih.csv | grep -E '^ *('${periodofinal}') *; *(\1)\s *; *-' )"

echo ${volFin[*]}

for _ln in $( grep -i -E "^UH" dadger.$arqName -n | cut -f1 -d":" )
do
  _line=$(  sed "$_ln"'!d' dadger.$arqName )
  #echo "_line : $_line"
  
  _uh=${_line:4:3}
  
  if [ "${volFin[$_uh]}" == "0" ]
  then
    _vol="  0.0"
  else
    _vol=$( echo "${volFin[$_uh]}" | sed -e :a -e 's/^.\{1,4\}$/ &/;ta' )
  fi
  
  sed "$_ln"'s/\(^.\{18\}\).\{6\}\(.*\)/\1 '"${_vol:0:5}"'\2/' dadger.$arqName -i
done

}

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

    echo /home/marco/PrevisaoPLD/cpas_ctl_common/scripts/newave23.sh
    /home/marco/PrevisaoPLD/cpas_ctl_common/scripts/newave23.sh

    ec=$?

    wait

    if [[ $ec == 1 ]]
    then 
       exit 1;
    fi

    cd "../${DC_Earm}/$ano$mes"

    echo $( pwd )
    

    echo /home/marco/PrevisaoPLD/cpas_ctl_common/scripts/decomp25.sh
    /home/marco/PrevisaoPLD/cpas_ctl_common/scripts/decomp25.sh

    ec=$?

    if [[ $ec == 1 ]]
    then
       exit 1;
    fi

    outputPath=$( pwd ) 

    #proxima iteração
    
    mesN=$(( 10#$mes + 1 ))
    anoN=$ano
    
    if [[ "$mesN" == "13" ]]
    then
        mesN="01"
        anoN=$(( $anoN + 1 ))
    fi

    printf -v mesN "%02i" $mesN

    numPeriodos
    echo periodofinal=$periodofinal


	echo "if [ -d ../$anoN$mesN ]"
    if [ -d ../$anoN$mesN ]
    then
        #atualiza DC
        cd ../$anoN$mesN

        for i in *; do
            AUXLOWER=$( echo $i | tr [:upper:] [:lower:] );
        
            if [ ! "$i" == "$AUXLOWER" ]; then
                echo -n "Convertendo $i para $AUXLOWER ... ";
                mv "$i" "$AUXLOWER";
                if [ -f "$AUXLOWER" ]; then
                    echo "ok";
                else
                    echo "erro";
                fi
            fi
        done

        echo $( pwd )
        replaceUH

        #atualiza NW
        cd ../..
        if [ -d $anoN$mesN ]
        then
            cd $anoN$mesN
            echo $( pwd )
            replaceEarmDger 
        fi

        #agenda nova execucao

        echo "AGENDAR NOVA EXECUCAO"
        echo "$0 $anoN$mesN"

        dt=$(date +%Y%m%d%H%M%S)
        ord=$(( 20 + 10#$mesN ))
        usr="encad"
        fn="/home/marco/PrevisaoPLD/cpas_ctl_common/queue/encadeado_earm_${anoN}${mesN}_${dt}"
        cmd="$0 ${anoN}${mesN} \"${DC_Earm}\""

#cmd="/home/marco/PrevisaoPLD/cpas_ctl_common/scripts/armazenamento_final.sh ${anoN}${mesN}" 

        printf -v newComm "%s\n" "ord=${ord}" "usr=${usr}" "dir=${dir}" "cmd=${cmd}" "ign=False" "cluster="
        
        echo ""
        echo "$newComm" #> ${fn}
        echo "$newComm" > ${fn}

        #echo "ord=${ord}" > ${fn}
        #echo "usr=${usr}" >> ${fn}
        #echo "dir=${dir}" >> ${fn}
        #echo "cmd=${cmd}"  >> ${fn}
        #echo "ign=False"  >> ${fn}
        #echo "cluster="  >> ${fn}

    fi
    

    
fi


exit 0;
