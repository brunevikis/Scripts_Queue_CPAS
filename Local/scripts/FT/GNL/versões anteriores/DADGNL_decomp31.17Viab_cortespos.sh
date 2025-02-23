#!/bin/bash

agendaDC(){
    echo "AGENDAR DC - $1"
    dt=$(date +%Y%m%d%H%M%S%3N)
    ord=$(( 20 ))
    usr="encad"
    fn="/home/producao/PrevisaoPLD/enercore_ctl_common/queue/encadeado_DC${ano}${mes}_${dt}"
    cmd="/home/producao/PrevisaoPLD/enercore_ctl_common/scripts/FT/decomp31.17Viab.sh"
    
    printf -v newComm "%s\n" "ord=${ord}" "usr=${usr}" "dir=$1" "cmd=${cmd}" "ign=False" "cluster="
    
    echo ""
    echo "$newComm" > ${fn}
}

AgendaProximaIteracao(){
    echo "AGENDAR NW - $1"
    dt=$(date +%Y%m%d%H%M%S%3N)
    ord=$(( 20 + 10#$mesN ))
    usr="encad"
    fn="/home/producao/PrevisaoPLD/enercore_ctl_common/queue/encadeado_NW${anoN}${mesN}_${dt}"
    cmd="/home/producao/PrevisaoPLD/enercore_ctl_common/scripts/FT/GNL/encad_dc_nw_mensal_3_2812_cortespos.sh $1"

    printf -v newComm "%s\n" "ord=${ord}" "usr=${usr}" "dir=$( pwd )" "cmd=${cmd}" "ign=False" "cluster="

    echo ""
    echo "$newComm" > ${fn}
}

par=$1
v="$(echo $0|sed -n 's/\(.*\/DADGNL_decomp\)\([0-9\.]*\)\([[:alpha:]_]*\.sh$\)/\2/p')"
gevazp=9.1.6

arqName=$( find . -maxdepth 1 -iname caso.dat -exec head -n 1 {} ';' | tr "[:upper:]" "[:lower:]" );
if [ -z "$arqName" ]; then
    echo -e "arquivo caso.dat nao encontrado ou vazio\n"
    exit 1
fi

echo "-----------[ Convertendo todos os arquivos para minusculas ]-----------";
for i in $( ls -p | grep "/$" -v ); do
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
                cp -b $origin_dir/DADGNL.$arqName $( pwd )/$dc/$ano$mes/dadgnl.$arqName
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

sed -i ':a;s/\(^   226  226[ 1]*\)0/\11/;ta' prevs.rv?
grep -q '^UH  309' dadger.rv? || sed -i '/^&UH$/a UH  309                                                                NW' dadger.rv?
grep -q '^CX  ' dadger.rv? || sed -i '/^FC  NEWCUT/a CX  176  173\nCX  176  174\nCX  176  175\nCX  132  146\nCX  132  147' dadger.rv?

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
    /usr/bin/dotnet "/home/producao/PrevisaoPLD/shared/price_tools/inviab/bin/Release/netcoreapp3.1/TrataInviab.dll" 1
    /usr/bin/dotnet /home/producao/PrevisaoPLD/shared/price_tools/inviab/bin/Release/netcoreapp3.1/TrataInviab.dll "flexTucurui"
    sed -i 's/^UH  309$/UH  309                                                                NW/g' dadger.rv?
    #sed -i '/^FC  NEWCUT/a CX  176  173\nCX  176  174\nCX  176  175\nCX  132  146\nCX  132  147' dadger.rv?
    echo "/home/producao/PrevisaoPLD/enercore_ctl_common/scripts/decomp.sh $v nao";
    /home/producao/PrevisaoPLD/enercore_ctl_common/scripts/decomp.sh "$v" nao;
    ec=$?
    if [ ! -f "sumario.$arq" ]
    then
      echo -e "\nRemovendo Inviabilidades - segunda iteracao\n"
      rm -f relato.bkp
      cp -pf ./relato.* ./relato.bkp
      /usr/bin/dotnet "/home/producao/PrevisaoPLD/shared/price_tools/inviab/bin/Release/netcoreapp3.1/TrataInviab.dll" 3
      /usr/bin/dotnet /home/producao/PrevisaoPLD/shared/price_tools/inviab/bin/Release/netcoreapp3.1/TrataInviab.dll "flexTucurui"
      sed -i 's/^UH  309$/UH  309                                                                NW/g' dadger.rv?
      #sed -i '/^FC  NEWCUT/a CX  176  173\nCX  176  174\nCX  176  175\nCX  132  146\nCX  132  147' dadger.rv?
      echo "/home/producao/PrevisaoPLD/enercore_ctl_common/scripts/decomp.sh $v nao";
      /home/producao/PrevisaoPLD/enercore_ctl_common/scripts/decomp.sh "$v" nao;
      ec=$?
    fi
  fi
fi

if [ $ec -eq 7 ]
then 
  echo " Tratar gap negativo "
  sed -i '/^FJ/a RT  CRISTA' "dadger.$arqName"
  /home/producao/PrevisaoPLD/enercore_ctl_common/scripts/decomp.sh "$v" nao;
  ec=$?
fi

if [ ! -f "sumario.$arq" ]&&[ $ec -eq 0 ]
then
  echo "  !!!!!!!!!!!!!!!!!!!!!!  "
  echo "  falha na convergencia   "
  echo "  !!!!!!!!!!!!!!!!!!!!!!  "
  ec=2
fi

# NW seguinte

cd "${origin_dir}"
cd ../..
mesN=$(( 10#$mes + 1 ))
anoN=$ano
if [[ "$mesN" == "13" ]]; then

  mesN="01"
  anoN=$(( $anoN + 1 ))
fi

printf -v mesN "%02i" $mesN

if [ -d $anoN$mesN ]; then    
  #agenda proximomes
  AgendaProximaIteracao "$anoN$mesN"
fi
exit $ec;