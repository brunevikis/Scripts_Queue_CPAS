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
    fn="/home/producao/PrevisaoPLD/enercore_ctl_common/queue/encadeado_DC${ano}${mes}_${dt}"
    cmd="/home/producao/PrevisaoPLD/enercore_ctl_common/scripts/FT/GNL/DADGNL_decomp31.24Viab_hibr_earNW_SF_cortesPOS_micropen_cortinho.sh"
    
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
  if [[ "$mes" == "01" || "$mes" == "05" || "$mes" == "09" ]]; then
    sed -i '99s/\(^.\{23\}\).\{2\}\(.*\)/\1 0\2/' "./dger.dat"     #Flag de fcf externa para 0
  else
    sed -i  '9s/\(^.\{23\}\).\{2\}\(.*\)/\1 0\2/' "./dger.dat"     #Numero de anos pos pra 0
    sed -i '99s/\(^.\{23\}\).\{2\}\(.*\)/\1 1\2/' "./dger.dat"     #Flag de fcf externa para 1
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
      echo /home/producao/PrevisaoPLD/enercore_ctl_common/scripts/FT/newave28.16.4_micropen_cortinho.sh 1
      /home/producao/PrevisaoPLD/enercore_ctl_common/scripts/FT/newave28.16.4_micropen_cortinho.sh 1
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
    cat > "nwlistop.dat" <<EOF
 2
FORWARD  (ARQ. DE DADOS)    : forward.dat
FORWARDH (ARQ. CABECALHOS)  : forwarh.dat
NEWDESP  (REL. CONFIGS)     : newdesp.dat
-----------------------------------------
 XXX XXX    PERIODOS INICIAL E FINAL
   1   $((13-10#0$mes))
 1-CMO           2-DEFICITS         3-ENA CONTROL.   4-EARM FINAL       5-ENA FIO BRUTA 6-EVAPORACAO    7-VERTIMENTO     38-SOMA AFL.PAS.                  43-VIOL. DA REST. LPP DEFL. MAX.       48-VOLUME BOMBEADO EST. BOMB.     53-VIOLACAO RHV
 8-VAZAO MIN.    9-GER.HIDR.CONT   10-GER. TERMICA  11-INTERCAMBIOS    12-MERC.LIQ.    13-VALOR AGUA   14-VOLUME MORTO   39-GER. EOLICA                    44-RHS DA REST. LPP TURB. MAX.         49-CONSUMO EST. BOMB.             54-VALOR FORMULA RHV
15-EXCESSO      16-GHMAX           17-OUTROS USOS   18-BENEF.INT/AGR   19-F.CORR.EC    20-GHTOTAL      21-ENA BRUTA      40-VEL. DE VENTO                  45-RHS DA REST. LPP DEFL. MAX.         50-VIOLACAO RHQ                   55-CUSTO VIOLACAO RHV
22-ACOPLAMENTO  23-INVASAO CG      24-PENAL.INV.CG. 25-ACIONAMENTO MAR 26-COPER        27-CTERM        28-CDEFICIT       41-VIOL. DA REST. FTE             46-VIOL. DAS REST. ELETRI ESP.         51-VALOR FORMULA RHQ
29-GER.FIO LIQ. 30-PERDA FIO       31-ENA FIO LIQ.  32-BENEF. GNL      33-VIOL.GHMIN   34-PERDAS       37-GEE            42-VIOL. DA REST. LPP TURB. MAX.  47-CUSTO VIOL. DAS REST. ELETRI ESP.   52-CUSTO VIOLACAO RHQ
 XX XX XX XX XX XX XX XX XX XX XX XX XX XX XX XX XX XX XX XX XX (SE 99 CONSIDERA TODAS)
 
-----------------------------------------------------------------------------------------------------------------------
 1-VOL.ARMAZ       2-GER.HID         3-VOL.TURB.     4-VOL. VERT.      5-VIOL.GHMIN    6-ENCH.MORTO   7-VIOL. DEPMIN. 15 - SOMA AFL. LAG PAR(p)-A  17 - VIOL. TURB. MAX.   19 - VIOL. DA REST. LPP TURB. MAX.   21 - RHS DA REST. LPP TURB. MAX.    23 - VOLUME DESVIADO DA USINA    25 - NIVEL DE JUSANTE           27 - GER.HID MAXIMA FPHA        29 - GER.HID MAXIMA FPHC 
 8-DESV. AGUA      9-DESV. POS.      10-DESVIO NEG.  11-VIOL. FPGHA   12-VAZAO AFL.  13-VAZAO INCREM. 14-VARM PCT.    16 - VIOL. DEFL. MAX.        18 - VIOL. TURB. MIN.   20 - VIOL. DA REST. LPP DEFL. MAX.   22 - RHS DA REST. LPP DEFL. MAX.    24 - VALOR DA AGUA DA USINA      26 - ALTURA DE QUEDA LIQUIDA    28 - COTA DE MONTANTE           30 - VALOR DA AGUA INCREMENTAL
 XX XX XX XX XX XX XX XX XX XX XX XX XX XX XX XX XX XX XX XX XX (SE 99 CONSIDERA TODAS)
 14
 XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX  (SE 999 CONSIDERA TODAS AS USINAS)
 999
EOF
    echo /home/producao/PrevisaoPLD/enercore_ctl_common/scripts/FT/nwlistop28.16.4_micropen.sh
    /home/producao/PrevisaoPLD/enercore_ctl_common/scripts/FT/nwlistop28.16.4_micropen.sh
    grep '^ *MEDIA' varmpuh*.out|sed "s/varmpuh\([0-9]\{3\}\).*MEDIA.\{7\}.\{$(((10#0$mes-1)*9))\}\(.\{9\}\).*/\1;\2/" > earm.uh
    rm varmpuh*.out
    confhd=$(find ../$anoN$mesN/ -iname "confhd.dat")
    mv "$confhd" "../$anoN$mesN/confhd.bkp"
    awk 'BEGIN{FS="; +"}
     NR==FNR{
     v[$1+0]=$2;
     if($1==156){v[295]=$2} #3M
     if($1==162){v[294]=$2} #Queimad
     if($1==155){v[308]=$2} #Retiro Baixo
     if($1==148){v[298]=$2} #Irape
     if($1==251){v[291]=$2/.55;if(v[291]>100){v[291]=100}} #SM
     if($1==257){v[303]=$2} #Peixe
     if($1==57){v[319]=$2} #Maua
     next}
     {FIELDWIDTHS = "5 30 6 5 25";if(FNR==1||FNR==2){print $0}else{
     printf "%s%s%6.2f%s%s\n",$1,$2,v[$1+0],$4,$5}}
     ' earm.uh "../$anoN$mesN/confhd.bkp" > "$confhd"
    modif=$(find "../$anoN$mesN" -iname 'modif.dat')
    mv "${modif}" "${modif}.bkp"
    awk -v "n=$n"  -v "y=$anoN" -v "m=$mesN" -f "/home/producao/PrevisaoPLD/enercore_ctl_common/awk/2024/SF+Paranapanema/modif_hibrido_nwlistop.awk" earm.uh "${modif}.bkp" >> "${modif}" || exit 111
    dcPaths=$( ls .. | grep -E '^20[0-9]{4}' -v )
    for dc in $dcPaths ; do
      if [ -d "../$dc/$anoN$mesN" ]; then
        dadger=$(find "../$dc/$anoN$mesN" -iname 'dadger.rv?')
        nn=$(sed -n "s/^& NO. DIAS DO MES 2 NA ULT. SEMANA *=> *\([0-9]*\)/\1/p" ${dadger})
        if [[ ${nn:0-2:1} -eq 0 ]]; then
          nn=0
        else
          nn=1
        fi
        q=$(sed -n "s/^& NO. SEMANAS NO MES INIC. DO ESTUDO=> *\([0-9]*\) \([0-9]*\)/\1/p" ${dadger})
        nn=$(( ${q:0-2:1}-$nn ))
        [[ nn -eq 0 ]] && nn=1;
        mv "$dadger" "../$dc/$anoN$mesN/dadger.bkp"
        awk 'BEGIN{FS="; +"}
         NR==FNR{v[$1+0]=$2+0;next}
         {FIELDWIDTHS="3 4 11 6 999"}
         /^UH/{printf "%s%s%s%6.2f%s\n",$1,$2,$3,v[$2+0],$5}
         !/^UH/{print $0}
         ' earm.uh "../$dc/$anoN$mesN/dadger.bkp" > "$dadger.tmp"
        awk -v n=$n -v m=$mesN -v nn=$nn -f "/home/producao/PrevisaoPLD/enercore_ctl_common/awk/2024/SF+Paranapanema/dadger_hibrido_nwlistop.awk"  earm.uh "$dadger.tmp" > "$dadger"
        rm "$dadger.tmp"
      fi
    done
    if [[ "$mes" == "01" ]]; then
      cp  cortes-060.dat "../${ano}02/cortes-pos.dat"
      cp  cortes-060.dat "../${ano}03/cortes-pos.dat"
      cp  cortes-060.dat "../${ano}04/cortes-pos.dat"
      cp  cortesh.dat "../${ano}02/cortesh-pos.dat"
      cp  cortesh.dat "../${ano}03/cortesh-pos.dat"
      cp  cortesh.dat "../${ano}04/cortesh-pos.dat"
    fi
    if [[ "$mes" == "05" ]]; then
      cp  cortes-060.dat "../${ano}06/cortes-pos.dat"
      cp  cortes-060.dat "../${ano}07/cortes-pos.dat"
      cp  cortes-060.dat "../${ano}08/cortes-pos.dat"
      cp  cortesh.dat "../${ano}06/cortesh-pos.dat"
      cp  cortesh.dat "../${ano}07/cortesh-pos.dat"
      cp  cortesh.dat "../${ano}08/cortesh-pos.dat"
    fi
    if [[ "$mes" == "09" ]]; then
      cp  cortes-060.dat "../${ano}10/cortes-pos.dat"
      cp  cortes-060.dat "../${ano}11/cortes-pos.dat"
      cp  cortes-060.dat "../${ano}12/cortes-pos.dat"
      cp  cortesh.dat "../${ano}10/cortesh-pos.dat"
      cp  cortesh.dat "../${ano}11/cortesh-pos.dat"
      cp  cortesh.dat "../${ano}12/cortesh-pos.dat"
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
  else    
    echo  "Erro na execução do newave. Cortes não encontrado"
    exit 1
  fi
fi
