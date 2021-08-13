#!/bin/bash

export LC_ALL=pt_BR.utf8

cota285()
{
  local q=$1
  if float_cond "$q < 5600"
  then 
   echo 82.5000
  elif float_cond "$q < 22700" #[ $q -lt 22700 ]
  then    
    echo $( float_eval "82.5 + ( 90.0 - 82.5 )*($q - 5600.0)/(22700.0 - 5600.0 )" 4 )    
  else
   echo 90.0000
  fi
}

cota287()
{
 local q=$1
#  if float_cond "$q < 24000"
  if float_cond "$q < 34000"
  then 
   echo 71.3000 
  else
   echo 70.5000
  fi
}

jusmed285()
{
  local cota=$1
  local cotaBase="90.0000"
  local jusmedBase="72.7100"  
  echo $( float_eval "$cota - ($cotaBase - $jusmedBase)" 4 )    
}

jusmed287()
{
  local cota=$1
  local cotaBase="70.5000"
  local jusmedBase="54.5900"  
  echo $( float_eval "$cota - ($cotaBase - $jusmedBase)" 4 )    
}




path=${1:-.}
#[ -z "$path" ] && path=".";

if [ -f /home/producao/PrevisaoPLD/cpas_ctl_common/scripts/functions.sh ]; then source /home/producao/PrevisaoPLD/cpas_ctl_common/scripts/functions.sh; 
else exit 1; fi;

numEstagios=$( numEstagiosDecomp "$path" )
numSemanasPassadas=$( numSemanasPassadas "$path" )
tipoDecomp=$( tipoDecomp "$path" )

echo numEstagios = $numEstagios
echo numSemanasPassadas = $numSemanasPassadas


arqNameO=$( find "$path" -maxdepth 1 -iname caso.dat -exec head -n 1 {} ';');


#285 jirau
#287 sto antonio

# primeiro mes prev.rvx
prevs=$( find "$path" -maxdepth 1 -iname prevs."$arqNameO" );
# segundo mes QUANTIL.CSV
quantil=$( find "$path" -maxdepth 1 -iname quantil.csv );
# dadger
dadger=$( find "$path" -maxdepth 1 -iname dadger."$arqNameO" );

dos2unix "$prevs"
dos2unix "$quantil"

dataEstudo=$( dataEstudoDecomp "$path" )

mesEstudo=$( date --date="$dataEstudo" +%b | tr [:lower:] [:upper:] )
mesSeguinte=$( date --date="$dataEstudo next month" +%b | tr [:lower:] [:upper:] )
anoSeguinte=$( date --date="$dataEstudo next month" +%Y )

grep -v -e "^AC\s\+28[57]\s\+\(JUSMED\|COTVOL\)" "$dadger" > "$dadger".temp
insertpoint=$( grep -e "^AC" "$dadger".temp -n | tail -n1 | cut -f1 -d":" )

echo "numEstagios=$numEstagios     tipo=$tipoDecomp"

textToInsert="&adicionado automaticamente COTVOL e JUSMED Jirau/Sto Antonio"


#echo ""
#echo "Jirau 285"

vaz285=$( echo $( grep -e "^\s*[0-9]\+\s*285" "$prevs" ) | cut -d" " -f$(( 3 + $numSemanasPassadas))-$(( 2 + $numEstagios + $numSemanasPassadas )) )
for est in $( eval echo {1..$numEstagios} )
do
  q285=$( echo $( echo $vaz285 ) | cut -d" " -f$(( $est )) )
  c=$( cota285 $q285 )
  j=$( jusmed285 $c )

  posfix="       "
if [ "$tipoDecomp" == "SEMANAL" ]; then posfix="$mesEstudo  $est"; fi;  
  
#&VAZ=$q285     COTVOL=$c     JUSMED=$j              $mesEstudo     $est  
  textToInsert=$textToInsert"
AC  285  JUSMED         $j                                      $posfix
AC  285  COTVOL        1         $c                             $posfix
AC  285  COTVOL        2         0.00000                             $posfix
AC  285  COTVOL        3         0.00000                             $posfix
AC  285  COTVOL        4         0.00000                             $posfix
AC  285  COTVOL        5         0.00000                             $posfix"

#   echo "VAZ=$q285     COTVOL=$c     JUSMED=$j              $mesEstudo     $est"  
done
vaz285=$( echo $( grep -e "[A-Z]\+\s\+,\s\+285" "$quantil" | cut -d"," -f5 ) )
#q285=$vaz285
c=$( cota285 $vaz285 )
j=$( jusmed285 $c )

#echo "VAZ=$vaz285     COTVOL=$c     JUSMED=$j              $mesSeguinte "  
  textToInsert=$textToInsert"
AC  285  JUSMED         $j                                      $mesSeguinte    $anoSeguinte      
AC  285  COTVOL        1         $c                             $mesSeguinte    $anoSeguinte      
AC  285  COTVOL        2         0.00000                             $mesSeguinte    $anoSeguinte      
AC  285  COTVOL        3         0.00000                             $mesSeguinte    $anoSeguinte      
AC  285  COTVOL        4         0.00000                             $mesSeguinte    $anoSeguinte      
AC  285  COTVOL        5         0.00000                             $mesSeguinte    $anoSeguinte"

#echo ""
#echo "Sto Antonio 287"

#echo $( grep -e "^\s*[0-9]\+\s*287" "$prevs" ) | cut -d" " -f$(( 3 + $numSemanasPassadas))-$(( 2 + $numEstagios + $numSemanasPassadas ))
#echo $( grep -e "[A-Z]\+\s\+,\s\+287" "$quantil" | cut -d"," -f5 )

vaz287=$( echo $( grep -e "^\s*[0-9]\+\s*287" "$prevs" ) | cut -d" " -f$(( 3 + $numSemanasPassadas))-$(( 2 + $numEstagios + $numSemanasPassadas )) )
for est in $( eval echo {1..$numEstagios} )
do
  q287=$( echo $( echo $vaz287 ) | cut -d" " -f$(( $est )) )
  c=$( cota287 $q287 )
  j=$( jusmed287 $c )  
  
posfix="       "
if [ "$tipoDecomp" == "SEMANAL" ]; then posfix="$mesEstudo  $est"; fi;  
  #echo "VAZ=$q287     COTVOL=$c     JUSMED=$j              $mesEstudo     $est"  
  textToInsert=$textToInsert"
AC  287  JUSMED         $j                                      $posfix
AC  287  COTVOL        1         $c                             $posfix
AC  287  COTVOL        2         0.00000                             $posfix
AC  287  COTVOL        3         0.00000                             $posfix
AC  287  COTVOL        4         0.00000                             $posfix
AC  287  COTVOL        5         0.00000                             $posfix"
done
vaz287=$( echo $( grep -e "[A-Z]\+\s\+,\s\+287" "$quantil" | cut -d"," -f5 ) )
#q285=$vaz285
c=$( cota287 $vaz287 )
j=$( jusmed287 $c )

#echo "VAZ=$vaz287     COTVOL=$c     JUSMED=$j              $mesSeguinte "  
textToInsert=$textToInsert"
AC  287  JUSMED         $j                                      $mesSeguinte    $anoSeguinte      
AC  287  COTVOL        1         $c                             $mesSeguinte    $anoSeguinte      
AC  287  COTVOL        2         0.00000                             $mesSeguinte    $anoSeguinte      
AC  287  COTVOL        3         0.00000                             $mesSeguinte    $anoSeguinte      
AC  287  COTVOL        4         0.00000                             $mesSeguinte    $anoSeguinte      
AC  287  COTVOL        5         0.00000                             $mesSeguinte    $anoSeguinte"

echo "$textToInsert" > "$dadger".temp.modif

sed -i "$insertpoint r ""$dadger"".temp.modif" "$dadger".temp
[ ! -f  "$dadger".origjirstoant ] && mv "$dadger" "$dadger".origjirstoant;

mv "$dadger".temp "$dadger"

exit 0





