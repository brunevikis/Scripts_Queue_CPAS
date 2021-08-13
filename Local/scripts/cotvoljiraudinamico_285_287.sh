#!/bin/bash

export LC_ALL=pt_BR.utf8

#atualizado em 2018-11-30
echo "Curvas cmont x cfuga atualizadas em 2018-11-30"
cmont287=( 70.50 71.28 71.12 70.83 70.92 71.22 71.30 71.30 71.30 71.30 71.30 71.30 71.30 )
cmont285=( 90.00 89.44 90.00 90.00 90.00 89.75 87.95 85.27 83.30 82.78 83.04 84.53 87.15 )           
cfuga287=( 54.59 55.23 57.21 58.40 58.11 56.07 53.54 50.86 48.55 47.44 48.04 49.96 52.58 )
cfuga285=( 72.71 72.91 73.71 74.24 74.02 73.21 72.39 71.80 71.49 71.40 71.44 71.66 72.14 )
vazaflu=( 33650 35800 37600 39050 40300 41400 42250 43000 43600 44050 44400 44555 47521 )
nabarra=( 90.00 89.50 89.00 88.50 88.00 87.50 87.00 86.50 86.00 85.50 85.00 84.74 85.43 )


cota285_new()
{
  local q=$1
  if float_cond "$q < 22700" #[ $q -lt 22700 ]
  then
    echo $( float_eval "82.5 + ( 90.0 - 82.5 )*($q - 5600.0)/(22700.0 - 5600.0 )" 4 )    
  else
   echo 90.0000
  fi
}

calcula_cota285()
{
  i=0
  local q=$1
  
  if [[ $q -gt 33650 ]]
  then
	for comp in "${vazaflu[@]}" #"${array[@]}"
	do
		if [[ $q -gt $comp ]]
		then
			i=$((i+1))
			j=$((i-1))
		fi
	done
  
  
	local vazsup=${vazaflu[$i]}
	#echo vazsup=$vazsup
	local vazinf=${vazaflu[$j]}
	#echo vazinf=$vazinf
	local nasup=${nabarra[$i]}
	local nainf=${nabarra[$j]}
  
	echo $( float_eval "(( $vazsup - $vazinf ) * ( $nainf ) + ( $q - $vazinf ) * ( $nasup - $nainf )) / ( $vazsup - $vazinf )" 4 )
  else
   echo 90.0000
  fi
}

cota287()
{
 local q=$1
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
  #local cotaBase="90.0000"
  #local jusmedBase="72.7100"  
  local cotaBase=${cmont285[$2]}
  local jusmedBase=${cfuga285[$2]}  
  echo $( float_eval "$cota - ($cotaBase - $jusmedBase)" 4 )    
}

jusmed287()
{
  local cota=$1
  #local cotaBase="70.5000"
  #local jusmedBase="54.5900" 
  local cotaBase=${cmont287[$2]}
  local jusmedBase=${cfuga287[$2]}    
  echo $( float_eval "$cota - ($cotaBase - $jusmedBase)" 4 )    
}

path=${1:-.}
echo $path "Path AQUIIIIIIIIIIIIIIIIIIIIIIIIIIIII"
#[ -z "$path" ] && path=".";

if [ -f /home/producao/PrevisaoPLD/cpas_ctl_common/scripts/functions.sh ]; then source /home/producao/PrevisaoPLD/cpas_ctl_common/scripts/functions.sh; 
else exit 1; fi;

numEstagios=$( numEstagiosDecomp "$path" )
numSemanasPassadas=$( numSemanasPassadas "$path" )
tipoDecomp=$( tipoDecomp "$path" )

echo numEstagios = $numEstagios
echo numSemanasPassadas = $numSemanasPassadas


arqNameO=$( find "$path" -maxdepth 1 -iname caso.dat -exec head -n 1 {} ';');

echo $arqNameO "Prevs AQUIIIIIIIIIIIIIIIIIIIIIIIIIIIII"
#285 jirau
#287 sto antonio

# primeiro mes prev.rvx
prevs=$( find "$path" -maxdepth 1 -iname prevs."$arqNameO" );
echo $prevs "Prevs AQUIIIIIIIIIIIIIIIIIIIIIIIIIIIII"
# segundo mes QUANTIL.CSV
quantil=$( find "$path" -maxdepth 1 -iname quantil.csv );
# dadger
dadger=$( find "$path" -maxdepth 1 -iname dadger."$arqNameO" );

dos2unix "$prevs"
dos2unix "$quantil"

dataEstudo=$( dataEstudoDecomp "$path" )

mesEstudo=$( date --date="$dataEstudo" +%b | tr [:lower:] [:upper:] )
mesSeguinte=$( date --date="$dataEstudo next month" +%b | tr [:lower:] [:upper:] )
anoEstudo=$( date --date="$dataEstudo" +%Y )
anoSeguinte=$( date --date="$dataEstudo next month" +%Y )
mesEstudoNum=$( date --date="$dataEstudo" +%-m )
mesSeguinteNum=$( date --date="$dataEstudo next month" +%-m )

#so vale a partir de 2019
if [ "$anoEstudo" == "2018" ]; then
mesEstudoNum=0
mesSeguinteNum=0
fi

grep -v -e "^AC\s\+28[57]\s\+\(JUSMED\|COTVOL\)" "$dadger" > "$dadger".temp
insertpoint=$( grep -e "^AC" "$dadger".temp -n | tail -n1 | cut -f1 -d":" )

echo "numEstagios=$numEstagios     tipo=$tipoDecomp"

textToInsert="&adicionado automaticamente COTVOL e JUSMED Jirau/Sto Antonio
&${mesEstudo} - CMONT  285=${cmont285[$mesEstudoNum]} CFUGA 285=${cfuga285[$mesEstudoNum]}
&${mesSeguinte} - CMONT 285=${cmont285[$mesSeguinteNum]} CFUGA 285=${cfuga285[$mesSeguinteNum]}"


#echo ""
#echo "Jirau 285"

vaz285=$( echo $( grep -e "^\s*[0-9]\+\s*285" "$prevs" ) | cut -d" " -f$(( 3 + $numSemanasPassadas))-$(( 2 + $numEstagios + $numSemanasPassadas )) )
for est in $( eval echo {1..$numEstagios} )
do
  q285=$( echo $( echo $vaz285 ) | cut -d" " -f$(( $est )) )
  c=$( calcula_cota285 $q285 )
  j=$( jusmed285 $c $mesEstudoNum )
  echo $q285 "AQUIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII"
  
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
echo valor sendo usado = $vaz285
c=$( calcula_cota285 $vaz285 )
j=$( jusmed285 $c $mesSeguinteNum )

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


textToInsert=$textToInsert"
&${mesEstudo} - CMONT  287=${cmont287[$mesEstudoNum]} CFUGA 287=${cfuga287[$mesEstudoNum]}
&${mesSeguinte} - CMONT 287=${cmont287[$mesSeguinteNum]} CFUGA 287=${cfuga287[$mesSeguinteNum]}"



vaz287=$( echo $( grep -e "^\s*[0-9]\+\s*287" "$prevs" ) | cut -d" " -f$(( 3 + $numSemanasPassadas))-$(( 2 + $numEstagios + $numSemanasPassadas )) )
for est in $( eval echo {1..$numEstagios} )
do
  q287=$( echo $( echo $vaz287 ) | cut -d" " -f$(( $est )) )
  c=$( cota287 $q287 )
  j=$( jusmed287 $c $mesEstudoNum )  
  
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
j=$( jusmed287 $c $mesSeguinteNum )

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





