#!/bin/bash

LANG=en_US.utf8
export LC_ALL=C.UTF-8

if [ -f /home/producao/PrevisaoPLD/enercore_ctl_common/scripts/functions.sh ]; then source /home/producao/PrevisaoPLD/enercore_ctl_common/scripts/functions.sh; 
else echo "Saindo" exit 1; fi;

agendaDCGNL(){
    echo "AGENDAR DCGNL - $1"
    dt=$(date +%Y%m%d%H%M%S%3N)
    ord=$(( 19 ))
    usr="encad"
    fn="/home/producao/PrevisaoPLD/enercore_ctl_common/queue/encadeado_earmNWsqn_DC${ano}${mes}_${dt}"
    cmd="/home/producao/PrevisaoPLD/enercore_ctl_common/scripts/GNL/DADGNL_decomp32.0.1Viab_earNWsqn_ANA_NW30.0.4.sh"
    
    printf -v newComm "%s\n" "ord=${ord}" "usr=${usr}" "dir=$1" "cmd=${cmd}" "ign=False" "cluster="
    
    echo ""
    echo "$newComm" > ${fn}
}
anomes=$1
nwDates=$( ls | grep -E '^20[0-9]{4}' | sort -n )
if [ -z $anomes ]; then
    anomes=$( echo "$nwDates" | head -n1 )
    first=1
fi
it=0
anoN=""
mesN=""
ano=${anomes:0:4}
mes=${anomes:4:2}
encadPath=$(pwd)

if [ -d $ano$mes ]; then
  cd $ano$mes
  echo "-----------[ Convertendo todos os arquivos para minusculas ]-----------";
  for i in $( ls -p | grep "/$ " -v ); do
    AUXLOWER=`echo $i | tr [:upper:] [:lower:]`;
    if [ ! "$i" == "$AUXLOWER" ]; then
      echo -n "Convertendo $i para $AUXLOWER ... ";
      mv $i $AUXLOWER;
      if [ -f $AUXLOWER ]; then
        echo "ok";
      else
        echo "erro";
      fi
    fi
  done
  /usr/bin/dos2unix *
  if [[ "$mes" == "01" || "$mes" == "05" || "$mes" == "09" || ! -z $first ]]; then
    sed -i '97s/\(^.\{23\}\).\{2\}\(.*\)/\1 0\2/' "./dger.dat"     #Flag de fcf externa para 0
  else
    sed -i  '9s/\(^.\{23\}\).\{2\}\(.*\)/\1 0\2/' "./dger.dat"     #Numero de anos pos pra 0
    sed -i '97s/\(^.\{23\}\).\{2\}\(.*\)/\1 1\2/' "./dger.dat"     #Flag de fcf externa para 1
    sed -i.bkp '/^POS/d' sistema.dat                               #Apaga linhas que começam com 'POS' no sistema.dat
    sed -i.bkp '/^POS/d' c_adic.dat                                #Apaga linhas que começam com 'POS' no c_adic.dat
  fi
  #Altera Adterm
  echo "/usr/bin/dotnet /home/producao/PrevisaoPLD/shared/price_tools/inviab/bin/Debug/netcoreapp3.1/TrataInviab.dll adterm "
  /usr/bin/dotnet /home/producao/PrevisaoPLD/shared/price_tools/inviab/bin/Debug/netcoreapp3.1/TrataInviab.dll "adterm"
  echo $( pwd )
  ree="$(date -d "$(pwd|grep -o '[^/]*$')01 +12months" "+%m %Y")"
  if [ -z $first ]; then
      sed '22s/\(^.\{21\}\).\{4\}\(.*\)/\1   1\2/' dger.dat -i
  fi
  if [ ! -f "cortesh.dat" ]; then
      echo /home/producao/PrevisaoPLD/enercore_ctl_common/scripts/newave30.0.4.sh 1
      /home/producao/PrevisaoPLD/enercore_ctl_common/scripts/newave30.0.4.sh 1
      ec=$?
      if [[ $ec == 1 ]]; then 
          exit 1;
      fi
  else
      echo  "Cortes já existente"
  fi
  if [ -f "cortesh.dat" ]; then
    mesN=$(printf '%02d' $(( 10#0$mes+1 )))
    anoN=$ano
    if [[ "$mesN" == "13" ]]; then
      mesN="01"
      anoN=$(( $anoN + 1 ))
    fi
    if [ -d ../$anoN$mesN ]; then
      curl -s --get --data-urlencode "path=$encadPath" --data-urlencode "date=$ano$mes" "http://10.206.194.210/api/encad/encad_nwsqn_restr" &
    fi
    if [[ "$mes" == "01" || "$mes" == "05" || "$mes" == "09" ]]; then
          cp cortes-060.dat "../${ano}$(printf '%02d' $(( 10#0$mes+1 )))/cortes-pos.dat"
          cp cortes-060.dat "../${ano}$(printf '%02d' $(( 10#0$mes+2 )))/cortes-pos.dat"
          cp cortes-060.dat "../${ano}$(printf '%02d' $(( 10#0$mes+3 )))/cortes-pos.dat"
          cp  cortesh.dat "../${ano}$(printf '%02d' $(( 10#0$mes+1 )))/cortesh-pos.dat"
          cp  cortesh.dat "../${ano}$(printf '%02d' $(( 10#0$mes+2 )))/cortesh-pos.dat"
          cp  cortesh.dat "../${ano}$(printf '%02d' $(( 10#0$mes+3 )))/cortesh-pos.dat"
    else
      if [[ ! -z $first ]]; then
        if [[ "$mes" == "02" || "$mes" == "06" || "$mes" == "10" ]]; then
          cp  cortes-060.dat "../${ano}$(printf '%02d' $(( 10#0$mes+1 )))/cortes-pos.dat"
          cp  cortes-060.dat "../${ano}$(printf '%02d' $(( 10#0$mes+2 )))/cortes-pos.dat"
          cp  cortesh.dat "../${ano}$(printf '%02d' $(( 10#0$mes+1 )))/cortesh-pos.dat"
          cp  cortesh.dat "../${ano}$(printf '%02d' $(( 10#0$mes+2 )))/cortesh-pos.dat"
        fi
        if [[ "$mes" == "03" || "$mes" == "07" || "$mes" == "11" ]]; then
          cp  cortes-060.dat "../${ano}$(printf '%02d' $(( 10#0$mes+1 )))/cortes-pos.dat"
          cp  cortesh.dat "../${ano}$(printf '%02d' $(( 10#0$mes+1 )))/cortesh-pos.dat"
        fi
      fi
    fi
    cd ..
    dcPaths=$( ls | grep -E '^20[0-9]{4}' -v )
    for dc in $dcPaths ; do
      if [ -d "$dc/$ano$mes" ]; then
        gnl=$(echo $dc | grep DCGNL)
        if [ ! "$gnl" == "" ]; then
          agendaDCGNL "$( pwd )/$dc/$ano$mes"
          sleep 2
          echo ""
        fi
      fi
    done
    wait
  else
    echo  "Erro na execução do newave. Cortes não encontrado"
    exit 1
  fi
fi
