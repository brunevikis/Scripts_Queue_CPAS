#!/bin/bash


FATOR=2.6298



#  Cod;VolMin;VolMax;CotaMin;CotaMax;Ree;Mercado;ProdEsp;PCV0;PCV1;PCV2;PCV3;PCV4;CodReal;Ez;PerdaVal;PerdaTipo;CanalFugaMed;Jusante;Reg;InDadger;RestricaoVolMin;RestricaoVolMax
ler_configuracao()
{
  local config=$( tail -n+2 configh.dat )
  uhs=( $( echo "$config" | cut -f1 -d';' ) )

  for _line in $config
  do

    IFS=';' read -r -a array <<< "$_line"
    
    local _uh=${array[0]}
    
    volMin[$_uh]=${array[1]}
    volMax[$_uh]=${array[2]}
    cotaMin[$_uh]=${array[3]}
    cotaMax[$_uh]=${array[4]}
    ree[$_uh]=${array[5]}
    mercado[$_uh]=${array[6]}
    prodEsp[$_uh]=${array[7]}
    pc0[$_uh]=${array[8]}
    pc1[$_uh]=${array[9]}
    pc2[$_uh]=${array[10]}
    pc3[$_uh]=${array[11]}
    pc4[$_uh]=${array[12]}
    codReal[$_uh]=${array[13]}
    ez[$_uh]=${array[14]}
    perda[$_uh]=${array[15]}
    perdaTipo[$_uh]=${array[16]}
    canalFuga[$_uh]=${array[17]}
    jusante[$_uh]=${array[18]}
    reg[$_uh]=${array[19]}
    inDadger[$_uh]=${array[20]}

    volMinMeta[$_uh]=${array[21]}
    volMaxMeta[$_uh]=${array[22]}

  done  
}

ler_configuracao2()
{
  
  pasta_anterior=$( sed '1!d' configm.dat )
  
  earmMax_mercado=( "0" $( sed '2!d' configm.dat ) )

  #earmMax_mercado[1]=203298
  #earmMax_mercado[2]=19957
  #earmMax_mercado[3]=51808
  #earmMax_mercado[4]=15317
  
  earmMeta_mercado=( "0" $( sed '3!d' configm.dat ) )

  #earmMeta_mercado[1]=91820.15
  #earmMeta_mercado[2]=17239.07
  #earmMeta_mercado[3]=14333.66
  #earmMeta_mercado[4]=5080.35

  #for _uh in ${uhs[@]}
  #do
  #  volMinMeta[$_uh]=${volMin[$_uh]}
  #  volMaxMeta[$_uh]=${volMax[$_uh]}    
  #done

  # execute on previous month to get initial reservoir state
pwd 
  unzip -p ../${pasta_anterior}/csv.zip dec_oper_usih.csv | grep -E '^ *1 *; *1 *; *-' > ./prev_dec_oper_usih.dat

}

ler_oper_usih()
{

  echo ler_oper_usih

  for _i in {1..320}
  do
    volIni[$_i]=0
  done


  local _uh=""
  local _vIni=""
  
  while read -r _line
  do
    IFS=';' read -r -a array <<< "$_line";
    
    _uh=$( echo ${array[4]} | bc )
    _vIni=$( echo ${array[10]} | tr - 0 | bc -l ) 
    _qDef=$( echo ${array[20]} | tr - 0 | bc -l ) 
    _qInc=$( echo ${array[17]} | tr - 0 | bc -l ) 
    volIni[$_uh]=$_vIni    
    qDef[$_uh]=$_qDef
    qInc[$_uh]=$_qInc
    
  done <<< "$( grep -E '^ *1 *; *1 *; *-' prev_dec_oper_usih.dat )"
}


atualiza_prod() 
{
  _uh=$1;
  _reg=${reg[$_uh]};

  #echo atualiza_prod $_uh

  if [ $_reg == "D" ]
  then    
    _cota=${cotaMax[$_uh]} 
  elif [ -z "${volIni[$_uh]}" -o $( echo "${volIni[$_uh]}==0" | bc ) -eq 1 ]  
  #elif [ $( echo "${volIni[$_uh]}==0" | bc ) -eq 1 ]
  then     
    _cota=${cotaMin[$_uh]}
  else    
    
    _volMin=${volMin[$_uh]}
    _vol=$( echo "${volIni[$_uh]} + $_volMin" | bc -l )


    _pc0=${pc0[$_uh]}
    _pc1=${pc1[$_uh]}
    _pc2=${pc2[$_uh]}
    _pc3=${pc3[$_uh]}
    _pc4=${pc4[$_uh]}
    
    _exp="($_pc0 * ($_vol - $_volMin) +  $_pc1 * ($_vol ^ 2 - $_volMin ^ 2) / 2.0 +  $_pc2 * ($_vol ^ 3 - $_volMin ^ 3) / 3.0 +  $_pc3 * ($_vol ^ 4 - $_volMin ^ 4) / 4.0 +  $_pc4 * ($_vol ^ 5 - $_volMin ^ 5) / 5.0 ) /($_vol - $_volMin)"
    _cota=$( echo "$_exp" |  sed -e 's/[eE]+*/*10^/g' | bc -l )

    #echo "$_vol ;  $_volMin ; $_pc0 ; $_pc1 ; $_pc2 ; $_pc3 ; $_pc4"
    #echo "$_exp"
    #echo "$_cota"

  fi

  cota[$_uh]=$_cota
  
  if [ ${perdaTipo[$_uh]} -eq 1 ] 
  then
    queda[$_uh]=$( echo "( $_cota - ${canalFuga[$_uh]} ) * ( 1 - ${perda[$_uh]}/100 )" | bc -l )
    #echo "queda[$_uh]=( $_cota - ${canalFuga[$_uh]} ) * ( 1 - ${perda[$_uh]}/100 )"
  else
    queda[$_uh]=$( echo "$_cota - ${canalFuga[$_uh]} - ${perda[$_uh]}" | bc -l )  
    #echo "queda[$_uh]=$_cota - ${canalFuga[$_uh]} - ${perda[$_uh]}"
  fi
  

    prod[$_uh]=$( echo "${prodEsp[$_uh]} * ${queda[$_uh]}" | bc -l )

    #echo "prod[$_uh]=${prodEsp[$_uh]} * ${queda[$_uh]}"

}

soma_prod_total()
{
  local _uh=$1;
  
  if [ -z "${prodTotal[$_uh]}" ]
  then
    
    #echo soma_prod_total $_uh

    atualiza_prod $_uh;

    local _prodTotal=${prod[$_uh]};

    if [ -n "${jusante[$_uh]}" -a "${jusante[$_uh]}" <> "0" ]
    then 
      local _jus=${jusante[$_uh]};
      if [ "${mercado[$_uh]}" == "${mercado[$_jus]}" ]
      then
        soma_prod_total $_jus
        _prodTotal=$( echo "${prodTotal[$_jus]} + $_prodTotal" | bc -l )
      fi
    fi
  
    prodTotal[$_uh]=$_prodTotal;
  fi

}

calcula_energia_armazenada()
{
  local _uh=$1;

  soma_prod_total $_uh;

  earm[$_uh]=$( echo "${prodTotal[$_uh]} * ${volIni[$_uh]} / $FATOR" | bc -l );
}

calcular_tudo()
{

  earm_mercado[1]=0
  earm_mercado[2]=0
  earm_mercado[3]=0
  earm_mercado[4]=0
  for _uh in ${uhs[@]}
  do
    calcula_energia_armazenada $_uh
    _mercado=${mercado[$_uh]}

    earm_mercado[$_mercado]=$( echo "${earm_mercado[$_mercado]} + ${earm[$_uh]}" | bc -l )

    #echo $_uh - ${mercado[$_uh]} - ${volIni[$_uh]} - ${prod[$_uh]} - ${prodTotal[$_uh]} - ${earm[$_uh]}
  done
}

atualiza_ficticias()
{
  for _uh in ${uhs[@]}
  do
    if [ -n "${codReal[$_uh]}" ] 
    then
      _uhReal=${codReal[$_uh]}
      _volIni=${volIni[$_uhReal]}

      #echo "$( echo "${ez[$_uh]} < 1" | bc -l )"


      if [ $( echo "${ez[$_uh]} < 1" | bc -l ) -eq 1 ]
      then
        _volIniMax=$( echo "${ez[$_uh]} * ( ${volMax[$_uhReal]} - ${volMin[$_uhReal]} ) " | bc -l )
        #echo "$_volIni > $_volIniMax"
        if [ $( echo "$_volIni > $_volIniMax" | bc -l ) -eq 1 ]
        then                
          _volIni=$_volIniMax
        fi
      fi
      volIni[$_uh]=$_volIni;
    fi

  done
}

abs()
{
  echo $( echo "a=$1/1;if(0>a)a*=-1;a" | bc -l )
}

atualiza_erro_mercado()
{  
  error1=$( abs "( ${earm_mercado[1]} - ${earmMeta_mercado[1]} )" | bc )
  error2=$( abs "( ${earm_mercado[2]} - ${earmMeta_mercado[2]} )" | bc )
  error3=$( abs "( ${earm_mercado[3]} - ${earmMeta_mercado[3]} )" | bc )
  error4=$( abs "( ${earm_mercado[4]} - ${earmMeta_mercado[4]} )" | bc )
  
  error=$( echo "scale=0;($error1 +  $error2 + $error3 + $error4)/1" | bc )
}

atualiza_fator_mercado(){
  fator_mercado[1]=$( echo "( ${earmMeta_mercado[1]} / ${earm_mercado[1]} )" | bc -l )
  fator_mercado[2]=$( echo "( ${earmMeta_mercado[2]} / ${earm_mercado[2]} )" | bc -l )
  fator_mercado[3]=$( echo "( ${earmMeta_mercado[3]} / ${earm_mercado[3]} )" | bc -l )
  fator_mercado[4]=$( echo "( ${earmMeta_mercado[4]} / ${earm_mercado[4]} )" | bc -l )
}


atingir_meta()
{
  atualiza_erro_mercado
  atualiza_fator_mercado

  iteration=1

  while [ $iteration -lt $max_iteration -a "$( echo "$error>$max_error" | bc )" == "1" ]
  do
    

    atualiza_erro_mercado
    atualiza_fator_mercado
    
    for _uh in ${uhs[@]}
    do
      if [ "${reg[$_uh]}" != "D" ]
        then
        
        _uhReal=$_uh
        if [ -n "${codReal[$_uh]}" ] 
        then  
          _uhReal=${codReal[$_uh]}      
          volIni[$_uhReal]=$( echo "scale=1 ; ${volIni[$_uhReal]} * sqrt(${fator_mercado[${mercado[$_uh]}]})" | bc -l )
        else
          volIni[$_uhReal]=$( echo "scale=1 ; ${volIni[$_uhReal]} * ${fator_mercado[${mercado[$_uhReal]}]}" | bc -l )
        fi
        
        # # echo "${volIni[$_uhReal]} > ( ${volMaxMeta[$_uhReal]} - ${volMin[$_uhReal]} )"
         if [ $( echo "${volIni[$_uhReal]} > ( ${volMaxMeta[$_uhReal]} - ${volMin[$_uhReal]} )" | bc ) == "1" ]
         then
#echo "$_uhReal :: ${volIni[$_uhReal]} > ( ${volMaxMeta[$_uhReal]} - ${volMin[$_uhReal]} )"
           volIni[$_uhReal]=$( echo "( ${volMaxMeta[$_uhReal]} - ${volMin[$_uhReal]} )" | bc )
         elif [ $( echo "${volIni[$_uhReal]} < ( ${volMinMeta[$_uhReal]} - ${volMin[$_uhReal]} )" | bc ) == "1" ]
         then
#echo "$_uhReal :: ${volIni[$_uhReal]} < ( ${volMinMeta[$_uhReal]} - ${volMin[$_uhReal]} )" 
           volIni[$_uhReal]=$( echo "( ${volMinMeta[$_uhReal]} - ${volMin[$_uhReal]} )" | bc )
         fi
      fi
    done

    atualiza_ficticias
    calcular_tudo 

    echo "iteracao $iteration : ${earm_mercado[@]}"

    iteration=$(( $iteration + 1 ))
  
  done
}



ler_configuracao

ler_configuracao2

ler_oper_usih


###
  atualiza_ficticias
  calcular_tudo

  echo "${earm_mercado[@]}"
###



max_iteration=20
max_error=1.0

fator_mercado[1]=1.0
fator_mercado[2]=1.0
fator_mercado[3]=1.0
fator_mercado[4]=1.0


echo ${earmMeta_mercado[@]}
atingir_meta


echo ""
echo "&BLOCO UH"

#setting UH block


cp dadger.* dadger_.bkp
# 
for _ln in $( grep -i -E "^UH" dadger.* -n | cut -f1 -d":" )
do
  _line=$(  sed "$_ln"'!d' dadger.* )
  #echo "_line : $_line"
  
  _uh=${_line:4:3}
  _vUtil=$( echo "${volMax[$_uh]} - ${volMin[$_uh]}" | bc )
  #echo "_vUtil : $_vUtil"

  if [ "$_vUtil" == "0" -o "${volIni[$_uh]}" == "0" ]
  then
    _vol="  0.0"
  else
    _vol=$( echo "scale=1 ; ( ${volIni[$_uh]} * 100 / $_vUtil ) " | bc -l )
    _vol=$( echo "$_vol" | sed -e :a -e 's/^.\{1,4\}$/ &/;ta' )
  fi
  # echo "$_uh volIni : ${volIni[$_uh]}  $_vol %"
  
  sed "$_ln"'s/\(^.\{19\}\).\{5\}\(.*\)/\1'"$_vol"'\2/' dadger.* -i
done


echo ""
echo "&BLOCO VI/QI"

for _ln in $( grep -i -E "^VI" dadger.* -n | cut -f1 -d":" )
do
  _line=$(  sed "$_ln"'!d' dadger.* )
  #echo "_line : $_line"
  
  _uh=${_line:4:3}
  _qDef=$( echo "scale=0 ; ( ${qDef[$_uh]} / 1 ) " | bc -l )


  _qDef=$( echo "$_qDef" | sed -e :a -e 's/^.\{1,4\}$/ &/;ta' )

  
  sed "$_ln"'s/\(^.\{14\}\).\{5\}\(.*\)/\1'"$_qDef"'/' dadger.* -i
done
for _ln in $( grep -i -E "^QI" dadger.* -n | cut -f1 -d":" )
do
  _line=$(  sed "$_ln"'!d' dadger.* )
  #echo "_line : $_line"
  
  _uh=${_line:4:3}
  _qInc=$( echo "scale=0 ; ( ${qInc[$_uh]} / 1 ) " | bc -l )

  _qInc=$( echo "$_qInc" | sed -e :a -e 's/^.\{1,4\}$/ &/;ta' )

  
  sed "$_ln"'s/\(^.\{9\}\).\{5\}\(.*\)/\1'"$_qInc"'/' dadger.* -i
done







echo "Terminado!"


exit 0

      





