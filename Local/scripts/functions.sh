#!/bin/bash


numSemanasPassadas(){    
    
    local path="$1"    
    [ -z "$path" ] && path=".";    
    
    local arqNameO=$( find "$path" -maxdepth 1 -iname caso.dat -exec head -n 1 {} ';' | tr [:upper:] [:lower:]);
    
    local vazLn=$( grep "^& VAZOES   " "$path/dadger.$arqNameO" -n | cut -f1 -d":" )
    
    local numSemL=$( sed "$(( $vazLn + 7))"'!d' "$path/dadger.$arqNameO" )
    
    local numSemPassadas=$( echo ${numSemL:44:4} | bc )
    
    echo $numSemPassadas;
}

numSemanasDecomp()
{
    local periodofinal=0
    
    local path="$1"    
    [ -z "$path" ] && path=".";
    
    
    local arqNameO=$( find "$path" -maxdepth 1 -iname caso.dat -exec head -n 1 {} ';' | tr [:upper:] [:lower:]);
    
    local vazLn=$( grep "^& VAZOES   " "$path/dadger.$arqNameO" -n | cut -f1 -d":" )
    
    local numSemL=$( sed "$(( $vazLn + 7))"'!d' "$path/dadger.$arqNameO" )
    local dias2MesL=$( sed "$(( $vazLn + 8))"'!d' "$path/dadger.$arqNameO")
    
    local numSem=$( echo ${numSemL:39:4} | bc )
    local dias2Mes=$( echo ${dias2MesL:39:4} | bc )
    
    if [ $numSem -ne 0 ]
    then    
        if [ $dias2Mes -eq 0 ]
        then
            periodofinal=$numSem
        else
            periodofinal=$(( $numSem - 1 ))
        fi
    else
        periodofinal=1
    fi
    
    echo $periodofinal;
}


numEstagiosDecomp()
{
    local periodofinal=0
    
    local path="$1"    
    [ -z "$path" ] && path=".";
    
    
    local arqNameO=$( find "$path" -maxdepth 1 -iname caso.dat -exec head -n 1 {} ';' | tr [:upper:] [:lower:]);
    
    local vazLn=$( grep "^& VAZOES   " "$path/dadger.$arqNameO" -n | cut -f1 -d":" )
    
    local numSemL=$( sed "$(( $vazLn + 7))"'!d' "$path/dadger.$arqNameO" )
    local dias2MesL=$( sed "$(( $vazLn + 8))"'!d' "$path/dadger.$arqNameO")
    
    local numSem=$( echo ${numSemL:39:4} | bc )
    local dias2Mes=$( echo ${dias2MesL:39:4} | bc )
    
    if [ $numSem -ne 0 ]
    then    
        periodofinal=$numSem
    else
        periodofinal=1
    fi
    
    echo $periodofinal;
}

tipoDecomp()
{
local periodofinal=0
    
    local path="$1"    
    [ -z "$path" ] && path=".";
    
    
    local arqNameO=$( find "$path" -maxdepth 1 -iname caso.dat -exec head -n 1 {} ';' | tr [:upper:] [:lower:]);    
    local vazLn=$( grep "^& VAZOES   " "$path/dadger.$arqNameO" -n | cut -f1 -d":" )    
    local numSemL=$( sed "$(( $vazLn + 7))"'!d' "$path/dadger.$arqNameO" )    
    
    local numSem=$( echo ${numSemL:39:4} | bc )
    
    if [ $numSem -ne 0 ]
    then    
        echo "SEMANAL"
    else
        echo "MENSAL"
    fi
}


dataEstudoDecomp()
{
    local path="$1"    
    [ -z "$path" ] && path=".";    
    
    local arqNameO=$( find "$path" -maxdepth 1 -iname caso.dat -exec head -n 1 {} ';' | tr [:upper:] [:lower:]);
    
    local vazLn=$( grep "^& VAZOES   " "$path/dadger.$arqNameO" -n | cut -f1 -d":" )
    
    local mesEstudoL=$( sed "$(( $vazLn + 4))"'!d' "$path/dadger.$arqNameO" )
    local anoEstudoL=$( sed "$(( $vazLn + 6))"'!d' "$path/dadger.$arqNameO" )
        
    local mes=$( echo ${mesEstudoL:39:2} | bc )
    local ano=$( echo ${anoEstudoL:39:4} | bc )
    
    echo "$ano-$mes-1";
}

function float_eval()
{
    local stat=0
    local result=0.0
    local scale=${2:-2}
    if [[ $# -gt 0 ]]; then        
        result=$(echo "scale=$scale; $1" | bc -q 2>/dev/null)
        stat=$?
        if [[ $stat -eq 0  &&  -z "$result" ]]; then stat=1; fi
    fi
    echo $result
    return $stat
}



#float_cond '10.0 < 9.3';
function float_cond()
{
    local cond=0
    if [[ $# -gt 0 ]]; then
        cond=$(echo "$*" | bc -q 2>/dev/null)
        if [[ -z "$cond" ]]; then cond=0; fi
        if [[ "$cond" != 0  &&  "$cond" != 1 ]]; then cond=0; fi
    fi
    local stat=$((cond == 0))
    return $stat
}


echo "functions.sh imported";