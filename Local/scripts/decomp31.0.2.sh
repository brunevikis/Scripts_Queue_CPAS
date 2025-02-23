#!/bin/bash

par=$1
v="$(echo $0|sed -n 's/\(.*\/decomp\)\([0-9\.]*\)\(\.sh$\)/\2/p')"
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

exit $ec;