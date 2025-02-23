#!/bin/bash

agendaDC(){
    echo "AGENDAR DC - $1"
    dt=$(date +%Y%m%d%H%M%S%3N)
    ord=$(( 20 + 10#0$mesN ))
    usr="encad"
    fn="/home/producao/PrevisaoPLD/enercore_ctl_common/queue/encadeado_DC${ano}${mes}_${dt}"
    cmd="/home/producao/PrevisaoPLD/enercore_ctl_common/scripts/decomp31.0.2Viab.sh"
    
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
    cmd="/home/producao/PrevisaoPLD/enercore_ctl_common/scripts/GNL/encad_dc_nw_mensal_3_29_earDC_regrasANA.sh $1"

    printf -v newComm "%s\n" "ord=${ord}" "usr=${usr}" "dir=$( pwd )" "cmd=${cmd}" "ign=False" "cluster="

    echo ""
    echo "$newComm" > ${fn}
}

par=$1
v="$(echo $0|sed -n 's/\(.*\/DADGNL_decomp\)\([0-9\.]*\)\([[:alnum:]_]*\.sh$\)/\2/p')"
gevazp=9

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
Dir_Atual=$(pwd)
n=6
pos=${#Dir_Atual}
n_6=$((pos-6))
anomes=${Dir_Atual:$n_6:$n}
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

if [ ! -f "$cortesPath" ]
then
  echo "Cuts file does not exists"
  exit 6;
fi


if [[ "$par" == "preliminar" ]]
then
   echo "/home/producao/PrevisaoPLD/enercore_ctl_common/scripts/decomp.sh $v nao";
   /home/producao/PrevisaoPLD/enercore_ctl_common/scripts/decomp.sh "$v" nao;
   ec=$?
else
   echo "/home/producao/PrevisaoPLD/enercore_ctl_common/scripts/decomp.sh $v";
   /home/producao/PrevisaoPLD/enercore_ctl_common/scripts/decomp.sh "$v" "$gevazp";
   ec=$?
fi

if [ $ec == 0 ]||[ $ec == 7 ]||[ $ec == 5 ]
then
  arq=$( cat caso.dat ) 
  if [ ! -f "sumario.$arq" ]
  then
    echo -e "\nRemovendo Inviabilidades\n"
    rm -f relato.bkp
    cp -pf ./relato.* ./relato.bkp
    /usr/bin/dotnet "/home/producao/PrevisaoPLD/shared/price_tools/inviab/bin/Debug/netcoreapp3.1/TrataInviab.dll" 1
    /usr/bin/dotnet /home/producao/PrevisaoPLD/shared/price_tools/inviab/bin/Debug/netcoreapp3.1/TrataInviab.dll "flexTucurui"
    echo "/home/producao/PrevisaoPLD/enercore_ctl_common/scripts/decomp.sh $v nao";
    /home/producao/PrevisaoPLD/enercore_ctl_common/scripts/decomp.sh "$v" nao;
    ec=$?
    if [ ! -f "sumario.$arq" ]
    then
      echo -e "\nRemovendo Inviabilidades - segunda iteracao\n"
      rm -f relato.bkp
      cp -pf ./relato.* ./relato.bkp
      /usr/bin/dotnet "/home/producao/PrevisaoPLD/shared/price_tools/inviab/bin/Debug/netcoreapp3.1/TrataInviab.dll" 3
      /usr/bin/dotnet /home/producao/PrevisaoPLD/shared/price_tools/inviab/bin/Debug/netcoreapp3.1/TrataInviab.dll "flexTucurui"
      echo "/home/producao/PrevisaoPLD/enercore_ctl_common/scripts/decomp.sh $v nao";
      /home/producao/PrevisaoPLD/enercore_ctl_common/scripts/decomp.sh "$v" nao;
      ec=$?
    fi
  fi
fi

if [ $ec -eq 7 ]; then
  echo " Tratar gap negativo "
  sed -i '/^FJ/a RT  CRISTA' "dadger.$arqName"
  /home/producao/PrevisaoPLD/enercore_ctl_common/scripts/decomp.sh "$v" nao;
  ec=$?
fi

if [ ! -f "sumario.$arq" ] && [ $ec -eq 0 ]
then
  echo "  !!!!!!!!!!!!!!!!!!!!!!  "
  echo "  falha na convergencia   "
  echo "  !!!!!!!!!!!!!!!!!!!!!!  "
  ec=2
fi

# NW seguinte

cd "${origin_dir}"
mesN=$(( 10#0$mes + 1 ))
anoN=$ano
if [[ "$mesN" == "13" ]]; then

  mesN="01"
  anoN=$(( $anoN + 1 ))
fi

printf -v mesN "%02i" $mesN
if [ -d ../../$anoN$mesN ]; then
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
  confhd=$(find ../../$anoN$mesN/ -iname "confhd.dat")
  mv "$confhd" "../../$anoN$mesN/confhd.bkp"
  awk -v n="$n" 'BEGIN{FS=" +; *"}
NR==FNR{if($1==n&&$3==1)
{if($12=="-"){v[$5+0]=0}else{v[$5+0]=$12};
if($6==156){v[295]=$12} #3M
if($6==162){v[294]=$12} #Queimad
if($6==155){v[308]=$12} #Retiro Baixo
if($6==148){v[298]=$12} #Irape
if($6==251){v[291]=$12/.55;if(v[291]>100){v[291]=100}} #SM
if($6==257){v[303]=$12} #Peixe
if($6==57){v[319]=$12} #Maua
};next}
{FIELDWIDTHS = "5 30 6 5 25";if(FNR==1||FNR==2){print $0}else{
printf "%s%s%6.2f%s%s\n",$1,$2,v[$1+0],$4,$5}}
' temp "../../$anoN$mesN/confhd.bkp" > "$confhd"

  modif=$(find "../../$anoN$mesN" -iname 'modif.dat')
  #v=($(awk -v "n=$n" 'BEGIN{
  #  FS=" +; *"
  #}{
  #  if($1==n&&$3==1) {
  #    vu[$5+0]=$11
  #    vum[$5+0]=$8
  #  }
  #}END{
  #  v=(vu[6]+vu[24]+vu[25]+vu[31])/(vum[6]+vum[24]+vum[25]+vum[31])
  #  if(v>=.3) {
  #    j=2700;jj=j
  #    (m>=3&&m<=10) ? p=3200 : p=3900;
  #    (m==2)? pp=3200 : pp=p;
  #    (m==10)? pp=3900 : pp=p;
  #  } else {
  #    (m>=3&&m<=10) ? j=2300 : j=2700;
  #    (m==2)? jj=2300 : jj=j;
  #    (m==10)? jj=2700 : jj=j;
  #    (m>=3&&m<=10) ? p=2900 : p=3900;
  #    (m==2)? pp=2900 : pp=p;
  #    (m==10)? pp=3900 : pp=p;
  #  }
  #  print j " " p " " jj " " pp
  #}' temp))
  #x=(45 46)
  #for i in 0 1; do
  #  if [[ $(sed -n "/^ USINA *${x[$i]}/,/^ USINA/{/^ USINA/b;p}" $modif|wc -l) -eq 1 ]]; then
  #    if [[ $(sed -n "/^ USINA *${x[$i]}/,/^ USINA/{/^ USINA/b;p}" $modif|grep -c 'VAZMINT') -gt 0 ]]; then
  #      sed -n "/^ USINA *${x[$i]}/,/^ USINA/{/^ USINA/b;p}" $modif|\
  #       awk -v "v=${v[$i]}" -v "vv=${v[$i+2]}" -v "m=$mesN" -v "y=$anoN" '
  #        BEGIN{FS=" +"}{
  #        printf "%s%2d%5d%8.2f\n"," VAZMINT  ",m,y,v;
  #        m=m+1;
  #        if(m==13){m=1;y=y+1};
  #        if(v!=vv) {printf "%s%2d%5d%8.2f\n"," VAZMINT  ",m+0,y,vv;}
  #        m=m+1;
  #        if(m==13){m=1;y=y+1};
  #        printf "%s%2d%5d%8.2f\n"," VAZMINT  ",m,y,$5}' >> "tmp${x[$i]}"
  #    else
  #      sed -n "/^ USINA *${x[$i]}/,/^ USINA/{/^ USINA/b;p}" $modif|\
  #       awk -v "v=${v[$i]}" -v "vv=${v[$i+2]}" -v "m=$mesN" -v "y=$anoN" '
  #        BEGIN{FS=" +"}{
  #        printf "%s%2d%5d%8.2f\n"," VAZMINT  ",m,y,v;
  #        m=m+1;
  #        if(m==13){m=1;y=y+1};
  #        if(v!=vv) {printf "%s%2d%5d%8.2f\n"," VAZMINT  ",m,y,vv;}
  #        m=m+1;
  #        if(m==13){m=1;y=y+1};
  #        printf "%s%2d%5d%8.2f\n"," VAZMINT  ",m,y,$3}' >> "tmp${x[$i]}"
  #    fi
  #  else
  #    sed -n "/^ USINA *${x[$i]}/,/^ USINA/{/^ USINA/b;p}" $modif|\
  #     awk -v "v=${v[$i]}" -v "vv=${v[$i+2]}" -v "m=$mesN" -v "y=$anoN" '
  #      BEGIN{FS=" +";n=1;mm=m+1;yy=y;if(mm==13){mm=1;yy=y+1};mmm=mm+1;yyy=yy;if(mmm==13){mmm=1;yyy=yy+1};o=0;q=0}
  #      /^ VAZMINT/{
  #      if($2==m&&$3==y){(v<$4)?x=v:x=$4;printf "%s%2d%5d%8.2f\n"," VAZMINT  ",m,y,x;vn=$4;next};
  #      if($2==mm&&$3==yy){(vv<$4)?x=vv:x=$4;printf "%s%2d%5d%8.2f\n"," VAZMINT  ",mm,yy,x;vn=$4;q=1;next};
  #      if($2==mmm&&$3==yyy){if(q!=1){printf "%s%2d%5d%8.2f\n"," VAZMINT  ",mm,yy,vv;q=1};print $0;o=1;next};
  #      if(o==0){printf "%s%2d%5d%8.2f\n"," VAZMINT  ",mmm,yyy,vn;o=1;print $0}else{print $0}}
  #      END{if(o==0){printf "%s%2d%5d%8.2f\n"," VAZMINT  ",mmm,yyy,vn;}}' >> "tmp${x[$i]}"
  #  fi
  #done
  mv "${modif}" "${modif}_.bkp"
  #sed '/^ USINA *45/,/^ USINA/{/^ USINA/b;d}' "$modif.bkp" |\
  #sed '/^ USINA *46/,/^ USINA/{/^ USINA/b;d}' |\
  #sed '/^ USINA *45/r tmp45' |\
  #sed '/^ USINA *46/r tmp46' >> "tmp"
  awk -v "n=$n"  -v "y=$anoN" -v "m=$mesN" -f "/home/producao/PrevisaoPLD/enercore_ctl_common/awk/2024/modif.awk" temp "${modif}_.bkp" >> "${modif}"
  #rm tmp45 tmp46 tmp
  re=$(find "../../$anoN$mesN" -iname 're.dat')
  mv "$re" "$re.bkp"
  awk -v "n=$n" -v "y=$anoN" -v "m=$mesN" -f "/home/producao/PrevisaoPLD/enercore_ctl_common/awk/2024/re.awk" temp "$re.bkp" > "$re"

  dcPaths=$( ls ../.. | grep -E '^20[0-9]{4}' -v )
    for dc in $dcPaths ; do
      if [ -d "../../$dc/$anoN$mesN" ]; then
        dadger=$(find "../../$dc/$anoN$mesN" -iname 'dadger.rv?')
        nn=$(sed -n "s/^& NO. DIAS DO MES 2 NA ULT. SEMANA *=> *\([0-9]*\)/\1/p" ${dadger})
        if [[ ${nn:0-2:1} -eq 0 ]]; then
          nn=0
        else
          nn=1
        fi
        q=$(sed -n "s/^& NO. SEMANAS NO MES INIC. DO ESTUDO=> *\([0-9]*\) \([0-9]*\)/\1/p" ${dadger})
        nn=$(( ${q:0-2:1}-$nn ))
        [[ nn -eq 0 ]] && nn=1;
        mv "$dadger" "../../$dc/$anoN$mesN/dadger.bkp"
        awk -v n="$n" 'BEGIN{FS=" +; *"}
NR==FNR{if($1==n&&$3==1)
{if($12=="-"){v[$5+0]=0}else{v[$5+0]=$12}};next}
{FIELDWIDTHS="3 4 11 6 999"}
/^UH/{printf "%s%s%s%6.2f%s\n",$1,$2,$3,v[$2+0],$5}
!/^UH/{print $0}
' temp "../../$dc/$anoN$mesN/dadger.bkp" > "$dadger.tmp"
        #sed -i "{/S\.Simao.*ANEEL/,/^CV/d};{/A\.Vermelha.*ANEEL/,/^CV/d};{/Marimbondo.*ANEEL/,/^CV/d}" "$dadger.tmp"
        awk -v n=$n -v m=$mesN -v nn=$nn -f "/home/producao/PrevisaoPLD/enercore_ctl_common/awk/2024/dadger.awk"  temp "$dadger.tmp" > "$dadger"
        rm "$dadger.tmp"
      fi
    done
  rm temp
  #agenda proximomes
  cd ../..
  AgendaProximaIteracao "$anoN$mesN"
fi
exit $ec;
