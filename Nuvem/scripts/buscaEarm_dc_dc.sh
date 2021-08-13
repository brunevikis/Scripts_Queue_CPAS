#!/bin/bash

LANG=en_US.utf8

origem=$1
destino=$2
men_sem=$3

periodofinal=1

numPeriodos()
{
    arqNameO=$( find "$origem" -maxdepth 1 -iname caso.dat -exec head -n 1 {} ';' | tr [:upper:] [:lower:]);
    
    vazLn=$( grep "^& VAZOES" "$origem/dadger.$arqNameO" -n | cut -f1 -d":" )
    
    numSemL=$( sed "$(( $vazLn + 7))"'!d' "$origem/dadger.$arqNameO" )
    dias2MesL=$( sed "$(( $vazLn + 8))"'!d' "$origem/dadger.$arqNameO")
    
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
}

replaceUH()
{
    arqName=$( find "$destino" -maxdepth 1 -iname caso.dat -exec head -n 1 {} ';' | tr [:upper:] [:lower:] );
    dgerDestino=$( find "$destino" -maxdepth 1 -iname dadger.$arqName );
    
    while read -r _line
    do
        IFS=';' read -r -a array <<< "$_line";
        
        _uh=$( echo ${array[4]} | bc )
        _vFin=$( echo ${array[11]} | tr - 0 | bc -l )
        volFin[$_uh]=$_vFin
        
    done <<< "$( unzip -p "$origem/csv.zip" dec_oper_usih.csv | grep -E '^ *('${periodofinal}') *; *(\1)\s *; *-' )"
    
    echo ${volFin[*]}
    echo "$dgerDestino"
    
    for _ln in $( grep -i -E "^UH" "$dgerDestino" -n | cut -f1 -d":" )
    do
      _line=$(  sed "$_ln"'!d' "$dgerDestino" )
      #echo "_line : $_line"
      
      _uh=${_line:4:3}
      
      if [ "${volFin[$_uh]}" == "0" ]
      then
        _vol="  0.0"
      else
        _vol=$( echo "${volFin[$_uh]}" | sed -e :a -e 's/^.\{1,4\}$/ &/;ta' )
      fi
      
      sed "$_ln"'s/\(^.\{18\}\).\{6\}\(.*\)/\1 '"${_vol:0:5}"'\2/' "$dgerDestino" -i
    done
}

if [ ! -d $destino ]
then
    echo "Pasta de destino não exite"
fi

if [ ! -d $origem ]
then
    echo "Pasta de origem não exite"
fi

if [ "$men_sem" == "men" ]
then
    numPeriodos
fi
echo "Buscando EARM final do estágio $periodofinal do caso $origem"

replaceUH && echo "Bloco UH do caso $destino substituido."
           
exit 0;
