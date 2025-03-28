#!/bin/bash

par=$1
v=31.0.2
gevazp=9

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
corteshPath=$( grep cortesh.dat "dadger.$arqName" | cut -c15- )


blocoFC=$( grep "^FC" dadger.$arqName )

linhacortes=$( grep -e "cortes.dat" dadger.$arqName -n | tail -n1 | cut -f1 -d":" )
linhacortesh=$( grep -e "cortesh.dat" dadger.$arqName -n | tail -n1 | cut -f1 -d":" )


origin_dir=$(pwd)

#ALTERAR DADGNL

echo "Alterando DADGNL RV0"
/usr/bin/dotnet /home/producao/PrevisaoPLD/shared/price_tools/inviab/bin/Release/netcoreapp3.1/TrataInviab.dll "RV0"


#definir diretorio para processamento  /opt/aplicacoes/newave/arquivo/recebido/$(date +%Y%m%d%H%M%s%N)
work_dir=/mnt/resource/decomp/$(date +%Y%m%d%H%M%s%N)/


if [ ! -f "$cortesPath" ]
then
  echo "Cuts file does not exists"
  exit 6;
fi

rm -r /mnt/resource/decomp/*

echo "-----------[ Copiando deck para pasta de processamento ] --------------"
echo cp -rp "${origin_dir}" "${work_dir}"

cp -rp "${origin_dir}" "${work_dir}"
wait;
cp -p "$cortesPath" "${work_dir}";
wait;
cp -p "$corteshPath" "${work_dir}"
wait;

echo "$cortesPath"

cd "${work_dir}"

sed 's/^FC/\&FC/' "dadger.$arqName" | sed "$linhacortesh"'iFC  NEWV21    cortesh.dat\nFC  NEWCUT    cortes.dat' > "dadger.$arqName.lower";
rm "dadger.$arqName";
mv "dadger.$arqName.lower" "dadger.$arqName";

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
    cp -f relato.bkp "${origin_dir}";
    /usr/bin/dotnet "/home/producao/PrevisaoPLD/shared/price_tools/inviab/bin/Release/netcoreapp3.1/TrataInviab.dll" 1
    /usr/bin/dotnet /home/producao/PrevisaoPLD/shared/price_tools/inviab/bin/Release/netcoreapp3.1/TrataInviab.dll "flexTucurui"
    echo "/home/producao/PrevisaoPLD/enercore_ctl_common/scripts/decomp.sh $v nao";
    /home/producao/PrevisaoPLD/enercore_ctl_common/scripts/decomp.sh "$v" nao;
    ec=$?
    if [ ! -f "sumario.$arq" ]
    then
      echo -e "\nRemovendo Inviabilidades - segunda iteracao\n"
      rm -f relato.bkp
      cp -pf ./relato.* ./relato.bkp
      cp -f relato.bkp "${origin_dir}";
      /usr/bin/dotnet "/home/producao/PrevisaoPLD/shared/price_tools/inviab/bin/Release/netcoreapp3.1/TrataInviab.dll" 3
      /usr/bin/dotnet /home/producao/PrevisaoPLD/shared/price_tools/inviab/bin/Release/netcoreapp3.1/TrataInviab.dll "flexTucurui"
      echo "/home/producao/PrevisaoPLD/enercore_ctl_common/scripts/decomp.sh $v nao";
      /home/producao/PrevisaoPLD/enercore_ctl_common/scripts/decomp.sh "$v" nao;
      ec=$?
    fi
  fi
fi

if [ $ec -eq 7 ]
then 
  cp cp -f ./relato.bkp "${origin_dir}"
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

sed '/^FC/d' "dadger.$arqName" | sed 's/^\&FC\s/FC /' > "dadger.$arqName.lower";
rm "dadger.$arqName";
mv "dadger.$arqName.lower" "dadger.$arqName";
rm -f "cortes.dat"
rm -f "cortesh.dat"
cp -f ./* "${origin_dir}";
wait;
rm -rf "${work_dir}"
exit $ec;