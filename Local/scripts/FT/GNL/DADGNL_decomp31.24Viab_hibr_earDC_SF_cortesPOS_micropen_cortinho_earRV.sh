#!/bin/bash

agendaDC(){
    echo "AGENDAR DC - $1"
    dt=$(date +%Y%m%d%H%M%S%3N)
    ord=$(( 20 ))
    usr="encad"
    fn="/home/producao/PrevisaoPLD/enercore_ctl_common/queue/encadeado_DC${ano}${mes}_${dt}"
    cmd="/home/producao/PrevisaoPLD/enercore_ctl_common/scripts/FT/decomp31.24Viab_cortinho.sh"
    
    printf -v newComm "%s\n" "ord=${ord}" "usr=${usr}" "dir=$1" "cmd=${cmd}" "ign=False" "cluster="
    
    echo ""
    echo "$newComm" > ${fn}
}

AgendaProximaIteracao(){
    echo "AGENDAR NW - $1"
    dt=$(date +%Y%m%d%H%M%S%3N)
    ord=$(( 20 + 10#0$mesN ))
    usr="encad"
    fn="/home/producao/PrevisaoPLD/enercore_ctl_common/queue/encadeado_NW${anoN}${mesN}_${dt}"
    cmd="/home/producao/PrevisaoPLD/enercore_ctl_common/scripts/FT/GNL/encad_dc_nw_mensal_3_28.16.4_micropen_hibr_earDC_SF_cortesPOS_cortinho_earRV.sh $1"

    printf -v newComm "%s\n" "ord=${ord}" "usr=${usr}" "dir=$( pwd )" "cmd=${cmd}" "ign=False" "cluster="

    echo ""
    echo "$newComm" > ${fn}
}

AgendaProximaRV(){
    echo "AGENDAR DC - $(pwd)"
    dt=$(date +%Y%m%d%H%M%S%3N)
    ord=19
    usr="encad"
    fn="/home/producao/PrevisaoPLD/enercore_ctl_common/queue/encadeado_DC${ano}${mes}rv$(( rv+1 ))_${dt}"
    cmd="/home/producao/PrevisaoPLD/enercore_ctl_common/scripts/FT/GNL/DADGNL_decomp31.24Viab_hibr_earDC_SF_cortesPOS_micropen_cortinho_earRV.sh"

    printf -v newComm "%s\n" "ord=${ord}" "usr=${usr}" "dir=$( pwd )" "cmd=${cmd}" "ign=False" "cluster="

    echo ""
    echo "$newComm" > ${fn}
}

par=$1
v="$(echo $0|sed -n 's/\(.*\/DADGNL_decomp\)\([0-9\.]*\)\([[:alnum:]_]*\.sh$\)/\2/p')"
gevazp=9.1.6

arqName=$( find . -maxdepth 1 -iname caso.dat -exec head -n 1 {} ';' | tr "[:upper:]" "[:lower:]" );
if [ -z "$arqName" ]; then
    echo -e "arquivo caso.dat nao encontrado ou vazio\n"
    exit 1
fi

echo "-----------[ Convertendo todos os arquivos para minusculas ]-----------";
for i in $( ls -p | grep '/$' -v ); do
    AUXLOWER=$(echo "$i" | tr "[:upper:]" "[:lower:]");
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

/usr/bin/dos2unix caso.dat;
arqName=$( find . -maxdepth 1 -iname caso.dat -exec head -n 1 {} ';' | tr "[:upper:]" "[:lower:]");
if [ -z "$arqName" ]; then
    echo -e "arquivo caso.dat nao encontrado ou vazio\n"
    exit 1
fi

/usr/bin/dos2unix "dadger.$arqName";
sed 's/CORTES.DAT/cortes.dat/g' "dadger.$arqName" | sed 's/CORTESH.DAT/cortesh.dat/g' > "dadger.$arqName.lower";
rm "dadger.$arqName";
mv "dadger.$arqName.lower" "dadger.$arqName";
cortesPath=$( grep cortes.dat "dadger.$arqName" | cut -c15- )
origin_dir=$(pwd)
n=6
pos=${#origin_dir}
n_6=$((pos-10))
anomes=${origin_dir:$n_6:$n}
ano=${anomes:0:4}
mes=${anomes:4:2}
echo $ano $mes
# ALTERAR DADGNL
echo "/usr/bin/dotnet /home/producao/PrevisaoPLD/shared/price_tools/inviab/bin/Debug/netcoreapp3.1/TrataInviab.dll dadgnl";
/usr/bin/dotnet /home/producao/PrevisaoPLD/shared/price_tools/inviab/bin/Debug/netcoreapp3.1/TrataInviab.dll "dadgnl"
cd ../..
dcPaths=$( ls | grep -E '^20[0-9]{4}' -v )
for dc in $dcPaths ; do
  if [ -d "$dc/$ano$mes" ]; then
    gnl=$(echo $dc | grep DCGNL)
    if [ "$gnl" == "" ]; then
      RV0=$(echo $dc | grep RV0)
      if [ ! "$RV0" == "" ]; then
        cd "$( pwd )/$dc/$ano$mes"
        echo "Alterando DADGNL RV0"
        /usr/bin/dotnet /home/producao/PrevisaoPLD/shared/price_tools/inviab/bin/Debug/netcoreapp3.1/TrataInviab.dll "RV0"
        cd ../..
        agendaDC "$( pwd )/$dc/$ano$mes"
        sleep 2
        echo ""
      else
        echo "Copiando DADGNL para sensibilidades"
        echo "cp -b $origin_dir/DADGNL.$arqName $( pwd )/$dc/$ano$mes/DADGNL.$arqName"
        cp -b "$origin_dir/DADGNL.$arqName" "$( pwd )/$dc/$ano$mes/dadgnl.$arqName"
        agendaDC "$( pwd )/$dc/$ano$mes"
        sleep 2
      fi
    fi
  fi
done

cd $origin_dir

/home/producao/PrevisaoPLD/enercore_ctl_common/scripts/FT/decomp${v}Viab_cortinho.sh
ec=$?

# NW seguinte

cd "${origin_dir}"
mesN=$(printf '%02d' $(( 10#0$mes+1 )))
anoN=$ano
if [[ "$mesN" == "13" ]]; then
  mesN="01"
  anoN=$(( $anoN + 1 ))
fi
rv=$(find -iname rv?|rev|cut -c 1)

if [ -f "dec_oper_sist.csv" ]; then
  dadger=$(find "." -iname 'dadger.rv?')
  n=$(sed -n "s/^& NO. DIAS DO MES 2 NA ULT. SEMANA *=> *\([0-9]*\)/\1/p" $dadger)
  if [[ n -eq 0 ]]; then
    n=0
  else
    n=1
  fi
  n=$(( $(sed -n "s/^& NO. SEMANAS NO MES INIC. DO ESTUDO=> *\([0-9]*\) \([0-9]*\)/\1/p" ${dadger})-$n ))
  [[ n -eq 0 ]] && n=1;
  unzip -p csv.zip dec_oper_usih.csv > temp
  dcPaths=$( ls ../../.. | grep -E '^20[0-9]{4}' -v )
  if [ -d "../../../$anoN$mesN" ] && [ "$n" -eq 1 ]; then
    confhd=$(find "../../../$anoN$mesN/" -iname "confhd.dat")
    mv "$confhd" "../../../$anoN$mesN/confhd.bkp"
    awk -v n="$n" 'BEGIN{FS=" +; *"}
NR==FNR{if($1==n&&$4==1)
{if($13=="-"){v[$6+0]=0}else{v[$6+0]=$13};
if($6==156){v[295]=$13} #3M
if($6==162){v[294]=$13} #Queimad
if($6==155){v[308]=$13} #Retiro Baixo
if($6==148){v[298]=$13} #Irape
if($6==251){v[291]=$13/.55;if(v[291]>100){v[291]=100}} #SM
if($6==257){v[303]=$13} #Peixe
if($6==57){v[319]=$13} #Maua
};next}
{FIELDWIDTHS = "5 30 6 5 25";if(FNR==1||FNR==2){print $0}else{
printf "%s%s%6.2f%s%s\n",$1,$2,v[$1+0],$4,$5}}
' temp "../../../$anoN$mesN/confhd.bkp" > "$confhd"
    modif=$(find "../../../$anoN$mesN" -iname 'modif.dat')
    mv "${modif}" "${modif}.bkp"
    awk -v "n=$n"  -v "y=$anoN" -v "m=$mesN" -f "/home/producao/PrevisaoPLD/enercore_ctl_common/awk/2024/backtest_2022/modif_hibrido.awk" temp "${modif}.bkp" >> "${modif}" || exit 111
    dcPaths=$( ls ../../.. | grep -E '^20[0-9]{4}' -v )
    for dc in $dcPaths; do
      if [ -d "../../../$dc/$anoN$mesN/rv0" ]; then
      dadgers=$(find "../../../$dc/$anoN$mesN/" -iname 'dadger.rv?')
        for dadger in $dadgers; do
          nn=$(sed -n "s/^& NO. DIAS DO MES 2 NA ULT. SEMANA *=> *\([0-9]*\)/\1/p" ${dadger})
          if [[ ${nn:0-2:1} -eq 0 ]]; then
            nn=0
          else
            nn=1
          fi
          q=$(sed -n "s/^& NO. SEMANAS NO MES INIC. DO ESTUDO=> *\([0-9]*\) \([0-9]*\)/\1/p" ${dadger})
          nn=$(( ${q:0-2:1}-$nn ))
          [[ nn -eq 0 ]] && nn=1;
          mv "$dadger" "$dadger.bkp"
          if echo "$dadger"|grep -q 'rv0'; then
            awk -v n="$n" 'BEGIN{FS=" +; *"}
             NR==FNR{if($1==n&&$4==1)
             {if($13=="-"){v[$6+0]=0}else{v[$6+0]=$13}};next}
             {FIELDWIDTHS="3 4 11 6 999"}
             /^UH/{printf "%s%s%s%6.2f%s\n",$1,$2,$3,v[$2+0],$5}
             !/^UH/{print $0}
             ' temp "$dadger.bkp" > "$dadger.tmp"
          else
            cp "$dadger.bkp" "$dadger.tmp"
          fi
          awk -v n=$n -v m=$mesN -v nn=$nn -f "/home/producao/PrevisaoPLD/enercore_ctl_common/awk/2024/backtest_2022/dadger_hibrido.awk"  temp "$dadger.tmp" > "$dadger"
          rm "$dadger.tmp"
        done
      fi
    done
    #agenda proximomes
    cd ../../..
    AgendaProximaIteracao "$anoN$mesN"
  fi
  cd "${origin_dir}"
  if [ -d "../rv$(( rv+1 ))" ] && [ "$n" -ne 1 ]; then
    n=1
    dadger=$(find "../rv$(( rv+1 ))" -iname 'dadger.rv?')
    mv "$dadger" "../rv$(( rv+1 ))/dadger.bkp"
    awk -v n="$n" 'BEGIN{FS=" +; *"}
    NR==FNR{if($1==n&&$3==1)
    {if($13=="-"){v[$6+0]=0}else{v[$6+0]=$13}};next}
    {FIELDWIDTHS="3 4 11 6 999"}
    /^UH/{printf "%s%s%s%6.2f%s\n",$1,$2,$3,v[$2+0],$5}
    !/^UH/{print $0}
    ' temp "../rv$(( rv+1 ))/dadger.bkp" > "$dadger"
    cd "$origin_dir/../rv$(( rv+1 ))"
    AgendaProximaRV
  fi
  cd "${origin_dir}" && rm temp
else
  echo -e "\nArquivos csv não encontrados\n"
fi
exit $ec;
