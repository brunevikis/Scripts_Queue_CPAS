#!/bin/bash

LANG=en_US.utf8

numPeriodos()
{
arqNameO=$( find "$outputPath" -maxdepth 1 -iname caso.dat -exec head -n 1 {} ';' | tr [:upper:] [:lower:]);

vazLn=$( grep "^& VAZOES" "$outputPath/dadger.$arqNameO" -n | cut -f1 -d":" )

numSemL=$( sed "$(( $vazLn + 7))"'!d' "$outputPath/dadger.$arqNameO" )
dias2MesL=$( sed "$(( $vazLn + 8))"'!d' "$outputPath/dadger.$arqNameO")

numSem=$(( 10#${numSemL:42:2} ))
dias2Mes=$(( 10#${dias2MesL:39:2} ))

#echo $numSem
#echo $dias2Mes

if [[ $numSem != 0 ]]
then	
    if [[ $dias2Mes == 0 ]]
    then
        periodofinal=$numSem
    else
        periodofinal=$(( $numSem - 1 ))
    fi
else
    periodofinal=1
fi

echo $periodofinal

}

SetK(){
    while read -r _line
    do
        IFS=';' read -r -a array <<< "$_line";
        #echo $_line
        if [ ${array[1]} == "1" ];
        then
            _vIni=$( echo ${array[20]} | tr - 0 | bc -l )
            #echo "I ${array[5]} ${_vIni}"
            volIni[${array[4]}]=$_vIni
        else
             _vFin=$( echo ${array[22]} | tr - 0 | bc -l )
             #echo "F ${array[5]} ${_vFin}"
             volFinS[${array[4]}]=$_vFin
        fi
    done <<< "$( unzip -p "$outputPath/csv.zip" dec_oper_sist.csv | grep -E '^ *('${periodofinal}'|'1') *;  *(\1) *; *('1')\s *' )"
    k=("" 1 1 1 1);
    echo ${volFinS[1]} ${volIni[1]}
    if [[ $( echo "scale=0; ${volIni[1]}*100/1" | bc -l) < $( echo "scale=0; ${volFinS[1]}*100/1" | bc -l) ]]; then k[1]=$( echo " ((${volFinS[1]}-0.978338997)/${volFinS[1]}) " | bc -l); fi
    if [[ $( echo "scale=0; (${volIni[1]}+3)*100/1" | bc -l) < $( echo "scale=0; ${volFinS[1]}*100/1" | bc -l) ]]; then k[2]=$( echo " ((${volFinS[2]}+9.718011902)/${volFinS[2]}) " | bc -l);
    else k[2]=$( echo " ((${volFinS[2]}-6.073757439)/${volFinS[2]}) " | bc -l);
    fi
    echo ${k[@]}
}

SetEarmDger()
{
unset _va
i=0
while read -r _line
do
    IFS=';' read -r -a array <<< "$_line";
    _vFin=$( echo ${array[10]} | tr - 0 | bc -l )
    #echo "${array[2]} ${_vFin}"
    volFinRee[$i]=$( echo 100 $( echo " ${_vFin} * ${k[${array[4]}]} " | bc -l) | awk '{if ($1 < $2) {print $1} else {print $2}}' )
    sm[$( echo ${array[2]} | tr - 0 | bc -l )]=${array[4]}
    ree[$i]=$( echo ${array[2]} | tr - 0 | bc -l )
    if [[ $( echo "${array[2]}" | bc -l) == 10 && $( echo ${k[1]} | awk '{if ($1 == 1 ) {print 1} else {print 0}}' ) -eq 0 ]]; then 
        volFinRee[$i]=$( echo 100 $( echo " (${_vFin}-1) * ${k[${array[4]}]} " | bc -l) | awk '{if ($1 < $2) {print $1} else {print $2}}' ); fi
    echo "${array[2]} ${sm[${ree[$i]}]} $( echo " scale=1 ; ${volFinRee[$i]}/1 " | bc -l )" $_vFin
    i=$i+1
done <<< "$( unzip -p "$outputPath/csv.zip" dec_oper_ree.csv | grep -E '^ *('${periodofinal}') *; *(\1)\s *' )"
volFinRee[6]=$( echo " ${volFinS[2]} * ${k[2]} " | bc -l);volFinRee[7]=${volFinRee[6]};
printf -v dgerV "%6.1f " ${volFinRee[@]}
echo $dgerV
sed '24s/\(^.\{20\}\).*/\1'"$dgerV"'/' "./$2/dger.dat" -i
sed '22s/\(^.\{21\}\).\{4\}\(.*\)/\1   0\2/' dger.dat -i
}

replaceUH()
{

arqName=$( find . -maxdepth 1 -iname caso.dat -exec head -n 1 {} ';' | tr [:upper:] [:lower:]);

while read -r _line
do
    IFS=';' read -r -a array <<< "$_line";
    
    _uh=$( echo ${array[4]} | bc )
    _vFin=$( echo ${array[11]} | tr - 0 | bc -l )
    if [ ${array[6]} == "SE" ] 
    then
        t=$(grep -i -E "^UH *$_uh " dadger.$arqName -n | cut -f2 -d":")
        if [[ $( echo "${t:7:10}" | bc -l) == 10 && $( echo ${k[1]} | awk '{if ($1 == 1 ) {print 1} else {print 0}}' ) -eq 0 ]]; then j=1; else j=0; fi
        t=$( echo $( echo " scale=2 ; ($_vFin-$j) * ${k[1]}/1 " | bc -l) 0 | awk '{if ($1 > $2) {print $1} else {print $2}}' )
		#echo ${array[4]} ${t:7:10} $t $j
    else 
        if [ ${array[6]} == "S" ]
        then
            t=$( echo " scale=2 ; $_vFin * ${k[2]}/1 " | bc -l)
        else
            t=$_vFin
        fi
    fi
    volFin[$_uh]=$( echo 100 $t | awk '{if ($1 < $2) {print $1} else {print $2}}' )
#echo $_uh $_vFin $t $( echo 100 $t | awk '{if ($1 < $2) {print $1} else {print $2}}' )
    
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
periodofinal=1

anomes=$1
DC_Earm=$2
#iter=$3

if [ -z $anomes ]
then
	anomes=$( ls -1 | head -n1 )    
fi

if [ -z $DC_Earm ]
then
	DC_Earm="DC_Earm"  
fi

#if [ -z $iter ]
#then
#    iter=0  
#fi

ano=${anomes:0:4}
mes=${anomes:4:2}

anoN=""
mesN=""

outputPath=""

dir=$( pwd )
echo $INICIO


echo $ano
echo $mes

if [ -d $ano$mes ]
then
    
    echo "ok"
    
#execução NW
    cd $ano$mes
    echo $( pwd )
    if [ ! -f "cortes.dat" ]; then
        echo /home/compass/sacompass/previsaopld/cpas_ctl_common/scripts/newave27.sh 1
        /home/compass/sacompass/previsaopld/cpas_ctl_common/scripts/newave27.sh 1
        ec=$?
        
        if [[ $ec == 1 ]]; then 
	
            exit 1;
        fi
    else
        echo  "Cortes já existente"
    fi
	
#Execução DC
    cd ../${DC_Earm}/$ano$mes

    echo $( pwd )
    

    echo /home/compass/sacompass/previsaopld/cpas_ctl_common/scripts/decomp301Viab.sh
    /home/compass/sacompass/previsaopld/cpas_ctl_common/scripts/decomp301Viab.sh

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
        SetK
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
            SetEarmDger 
        fi

        #agenda nova execucao

        echo "AGENDAR NOVA EXECUCAO"
        echo "$0 $anoN$mesN"

        dt=$(date +%Y%m%d%H%M%S)
        ord=$(( 20 + 10#$mesN ))
        usr="encad"
        fn="/home/compass/sacompass/previsaopld/cpas_ctl_common/queue/encadeado_earm_${anoN}${mesN}_${dt}"
        cmd="$0 ${anoN}${mesN} \"${DC_Earm}\""

        printf -v newComm "%s\n" "ord=${ord}" "usr=${usr}" "dir=${dir}" "cmd=${cmd}" "ign=False" "cluster="
        
        echo ""
        echo "$newComm" #> ${fn}
        echo "$newComm" > ${fn}
    fi
    

    
fi


exit 0;