#!/bin/bash
 export LC_ALL=C.UTF-8
par=$1
v="$(echo $0|sed -n 's/\(.*\/decomp\)\([0-9\.]*\)\([[:alnum:]_]*\.sh$\)/\2/p')"
gevazp=10

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
sed 's/CORTES\([-0-9]*\).DAT/cortes\1.dat/ig' "dadger.$arqName" | sed 's/CORTESH.DAT/cortesh.dat/g' > "dadger.$arqName.lower";
rm "dadger.$arqName";
mv "dadger.$arqName.lower" "dadger.$arqName";

cortesPath=$( grep 'cortes-[0-9]\{3\}.dat' "dadger.$arqName" | cut -c15- )

if [ ! -f "$cortesPath" ]; then
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

if [ $ec == 0 ]||[ $ec == 7 ]||[ $ec == 5 ]; then
  arq=$( cat caso.dat ) 
  if [ ! -f "sumario.$arq" ]
  then
    echo -e "\nRemovendo Inviabilidades\n"
    rm -f relato.bkp
    cp -pf ./relato.* ./relato.bkp
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
      /usr/bin/dotnet "/home/producao/PrevisaoPLD/shared/price_tools/inviab/bin/Release/netcoreapp3.1/TrataInviab.dll" 3
      /usr/bin/dotnet /home/producao/PrevisaoPLD/shared/price_tools/inviab/bin/Release/netcoreapp3.1/TrataInviab.dll "flexTucurui"
      echo "/home/producao/PrevisaoPLD/enercore_ctl_common/scripts/decomp.sh $v nao";
      /home/producao/PrevisaoPLD/enercore_ctl_common/scripts/decomp.sh "$v" nao;
      ec=$?
    fi
  fi
fi

if [ $ec -eq 7 ]; then 
  echo " Tratar gap negativo "
  sed -i '/^FJ/a RT  CRISTA' "dadger.$arqName"
  sed -i '/^FA/a RT  CRISTA' "dadger.$arqName"
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

exit $ec;