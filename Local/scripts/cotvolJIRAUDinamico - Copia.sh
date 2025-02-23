#!/bin/bash

export LC_ALL=pt_PT.UTF-8

#atualizado em 2023-04-05
echo "Curvas cmont x cfuga atualizadas em 2023-04-05"
cmont287=( 70.77 70.77 70.49 70.47 70.57 70.79 71.11 71.08 71.00 70.92 70.65 70.66 70.94 )
cmont285=( 89.19 89.19 88.80 88.83 89.19 89.49 88.54 85.67 83.46 82.52 82.71 84.43 87.73 )
cfuga287=( 56.15 56.15 57.54 59.22 58.50 56.35 54.47 51.35 48.11 46.60 46.94 49.17 53.35 )
cfuga285=( 73.69 73.69 74.51 75.40 74.83 74.01 72.84 71.82 71.14 70.74 70.76 71.27 72.22 )
vazaflu=( 3805 3836 4010 4012 4175 4196 4233 4467 4561 4583 4639 4676 4836 4856 4870 4909 4972 5002 5052 5183 5550 5600 5662 6041 6165 6211 6264 6344 6350 6371 6567 6571 6800 7010 7035 7070 7102 7217 7376 7488 7569 8124 8138 8160 8308 8379 8695 9034 9238 9482 9621 9626 9870 10400 10447 10569 10600 10913 11088 11635 11644 12218 12311 12996 13334 13524 13604 13733 13817 13994 14444 14685 14766 14858 15246 15472 15855 15900 16600 17088 17261 17305 17566 17662 19225 19617 20033 20690 20833 20940 21314 22116 22580 22700 22734 23603 23900 24212 24344 24400 24507 24622 24853 24858 25466 26307 26678 27059 27484 27600 28035 28512 28664 28685 29414 30612 30709 31004 31914 32086 32553 32652 33481 33650 33833 34123 34578 34663 34785 35474 35496 35542 35712 35800 35864 36864 37004 37209 37367 37560 37600 37607 37858 37865 38372 38499 38570 38611 38928 38970 39050 39085 39518 39851 39902 39908 40300 40516 41400 42250 43000 43600 44050 44400 44555 47521 )
nabarra=( 81.71 81.73 82.50 82.50 82.50 82.50 82.50 82.50 82.50 82.50 82.50 82.50 82.50 82.50 82.50 82.50 82.50 82.50 82.50 82.50 82.50 82.50 82.56 82.73 82.78 82.80 82.83 82.87 82.93 82.94 82.97 83.01 83.10 83.17 83.19 83.21 83.21 83.26 83.33 83.38 83.42 83.67 83.68 83.69 83.75 83.79 83.93 84.08 84.18 84.29 84.35 84.35 84.46 84.70 84.72 84.78 84.80 84.93 85.01 85.26 85.27 85.53 85.57 85.88 86.03 86.12 86.15 86.21 86.25 86.33 86.53 86.64 86.68 86.72 86.90 87.34 87.50 87.60 87.70 87.73 87.80 87.83 87.90 87.99 88.70 88.88 89.07 89.36 89.43 89.48 89.50 90.00 90.00 90.00 90.00 90.00 90.00 90.00 90.00 90.00 90.00 90.00 90.00 90.00 90.00 90.00 90.00 90.00 90.00 90.00 90.00 90.00 90.00 90.00 90.00 90.00 90.00 90.00 90.00 90.00 90.00 90.00 90.00 90.00 89.97 89.94 89.86 89.84 89.81 89.63 89.62 89.62 89.58 89.54 89.52 89.20 89.13 89.09 88.91 88.89 88.88 88.88 88.87 88.82 88.80 88.66 88.64 88.62 88.51 88.50 88.50 88.50 88.31 88.19 88.18 88.17 88.10 88.00 87.93 87.50 87.00 86.50 86.00 85.50 85.00 84.74 )

calcula_cota285_new()
{
  i=0
  local q=$1
  
  if float_cond "$q < 47521"
  then
	if float_cond "$q > 3805"
	then
	  for comp in "${vazaflu[@]}" #"${array[@]}"
	  do
		  if float_cond "$q > $comp"
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
	  #echo $( float_eval "(( $vazsup - $vazinf ) * ( $nainf ) + ( $q - $vazinf ) * ( $nasup - $nainf )) / ( $vazsup - $vazinf )" 4 )
	  local valor=$( float_eval "(( $vazsup - $vazinf ) * ( $nainf ) + ( $q - $vazinf ) * ( $nasup - $nainf )) / ( $vazsup - $vazinf )" 4 )
	  echo $( round $valor)"00"
	else
	 echo 82.5000
	fi 
  else
   echo 85.4000
  fi
}

calcula_cota285()
{
  i=0
  local q=$1
  
  if float_cond "$q > 33650"
  then
	for comp in "${vazaflu[@]}" #"${array[@]}"
	do
		if float_cond "$q > $comp"
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

cota285_old()
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


cota285()
{
  local q=$1
  if float_cond "$q < 37800"
  then 
   echo 90.0000
  elif float_cond "$q < 50000" #[ $q -lt 22700 ]
  then
	echo $( float_eval "-0.0238 * ($q / 1000) * ($q / 1000) + ( 1.6979 )*($q / 1000) + 59.734" 4 )    
  else
   echo 86.0000
  fi
}
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



cota287()
{
 local q=$1
  if float_cond "$q < 34000"
  then 
   echo 71.3000 
  else
   echo 71.3000
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
#[ -z "$path" ] && path=".";

if [ -f /home/producao/PrevisaoPLD/enercore_ctl_common/scripts/functions.sh ]; then source /home/producao/PrevisaoPLD/enercore_ctl_common/scripts/functions.sh; 
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
  c=$( calcula_cota285_new $q285 )
  j=$( jusmed285 $c $mesEstudoNum )

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
c=$( calcula_cota285_new $vaz285 )
#echo valorUsadoNoTeste = $vaz285
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





