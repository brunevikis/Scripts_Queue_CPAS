#!/bin/bash

LANG=en_US.utf8


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

while read -r _line
do
    IFS=';' read -r -a array <<< "$_line";
    
    _uh=$( echo ${array[4]} | bc )
    _vFin=$( echo ${array[11]} | tr - 0 | bc -l )
    volFin[$_uh]=$_vFin
    
done <<< "$( unzip -p "$outputPath/csv.zip" dec_oper_usih.csv | grep -E '^ *1 *; *1 *; *-' )"

echo ${volFin[*]}

for _ln in $( grep -i -E "^UH" dadger.* -n | cut -f1 -d":" )
do
  _line=$(  sed "$_ln"'!d' dadger.* )
  #echo "_line : $_line"
  
  _uh=${_line:4:3}
  
  if [ "${volFin[$_uh]}" == "0" ]
  then
    _vol="  0.0"
  else
    _vol=$( echo "${volFin[$_uh]}" | sed -e :a -e 's/^.\{1,4\}$/ &/;ta' )
  fi
  
  sed "$_ln"'s/\(^.\{19\}\).\{5\}\(.*\)/\1'"${_vol:0:5}"'\2/' dadger.* -i
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
    
done <<< "$( unzip -p "$outputPath/csv.zip" dec_oper_ree.csv | grep -E '^ *1 *; *1 *' )"

printf -v dgerV "%6.1f " ${_va[@]}

sed '24s/\(^.\{20\}\).*/\1'"$dgerV"'/' dger.dat  -i

}

echo $INICIO


echo $ano
echo $mes

if [ -d $ano$mes ]
then
    
    echo "ok"
    
    cd $ano$mes

    echo $( pwd )

    /opt/aplicacoes/cpas_ctl/scripts/newave22

    ec=$?

    wait

    if [[ $ec == 1 ]]
    then 
       exit 1;
    fi

    cd "../${DC_Earm}/$ano$mes"

    echo $( pwd )
    

    /opt/aplicacoes/cpas_ctl/scripts/decomp24

    ec=$?

    if [[ $ec == 1 ]]
    then
       exit 1;
    fi

    outputPath=$( pwd ) 

    #proxima iteração
    
    mesN=$(( $mes + 1 ))
    anoN=$ano
    
    if [[ "$mesN" == "13" ]]
    then
        mesN="01"
        anoN=$(( $anoN + 1 ))
    fi

    if [ -d ../$anoN$mesN ]
    then
        #atualiza DC
        cd ../$anoN$mesN
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
        ord=$(( 20 + $mesN ))
        usr="encad"
        fn="/home/producao/PrevisaoPLD/cpas_ctl_common/queue/encadeado_earm_${anoN}${mesN}_${dt}"
        cmd="$0 ${anoN}${mesN} \"${DC_Earm}\""

#cmd="/home/producao/PrevisaoPLD/cpas_ctl_common/scripts/armazenamento_final.sh ${anoN}${mesN}" 

        printf -v newComm "%s\n" "ord=${ord}" "usr=${usr}" "dir=${dir}" "cmd=${cmd}" "ign=False" "cluster="

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





#run newave

#run decomp

#copy ree earmfim/ree to next dger.dat

#copy usih volfim to next dadger UH



grep -E "^\s*1\s*;\s*1\s*;\s*-" dec_oper_usih.csv | cut -f5,12 -d";" | head


grep -E "^\s*1\s*;\s*1\s*;" dec_oper_ree.csv | cut -f3,4,11 -d";" | head

grep -E "^UH" dadger.rv1 | paste earmfim_uh.csv -


unzip -p ../${pasta_anterior}/csv.zip dec_oper_usih.csv | grep -E '^ *1 *; *1 *; *-' > ./prev_dec_oper_usih.dat


while read -r _line
do
    IFS=';' read -r -a array <<< "$_line";
    
    echo ${array[*]}

#    _uh=$( echo ${array[4]} | bc )
#    _vIni=$( echo ${array[10]} | tr - 0 | bc -l ) 
#    _qDef=$( echo ${array[20]} | tr - 0 | bc -l ) 
#    _qInc=$( echo ${array[17]} | tr - 0 | bc -l ) 
#    volIni[$_uh]=$_vIni    
#    qDef[$_uh]=$_qDef
#    qInc[$_uh]=$_qInc
    
#done <<< "$( grep -E '^ *1 *; *1 *; *-' prev_dec_oper_usih.dat )"
done <<< "$( unzip -p csv.zip dec_oper_usih.csv | grep -E '^ *1 *; *1 *; *-' )"





earmMax_mercado[1]=203298
earmMax_mercado[2]=19957
earmMax_mercado[3]=51808
earmMax_mercado[4]=15317