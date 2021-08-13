#!/bin/bash

# script para execucao do decomp

/usr/bin/dos2unix caso.dat;
arqName=$( find . -maxdepth 1 -iname caso.dat -exec head -n 1 {} ';' | tr [:upper:] [:lower:]);

gevazpPath="/home/compass/sacompass/previsaopld/shared/gevazp/8.0/"


echo "-----------[ Convertendo todos os arquivos para minusculas ]-----------";
for i in *; do
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

echo "$arqName"

/usr/bin/dos2unix $arqName;

cp "${gevazpPath}gevazp.lic" ./gevazp.lic

if [ ! -f modif.dat ] 
then
    cp "${gevazpPath}modif.dat" ./modif.dat
fi

if [ ! -f regras.dat  ]
then
    cp "${gevazpPath}regras.dat" ./regras.dat
fi

if [ ! -f postos.dat  ]
then
    cp "${gevazpPath}postos.dat" ./postos.dat
fi

if [ ! -f gevazp.dat  ]
then
    cp "${gevazpPath}gevazp.dat" ./gevazp.dat
fi

if [ ! -f arquivos.dat  ]
then
    cp "${gevazpPath}arquivos.dat" ./arquivos.dat
fi

/usr/bin/dos2unix arquivos.dat;

echo "-----------[ Executando ConverteNomesArquivosDecomp${ver} -----------";
/opt/aplicacoes/decomp/bin/convertenomesdecomp_30;
echo -e "\n";

echo "Convertendo tudo em $arqName para minusculas";
sed -e 's/\(.*\)/\L\1/' $arqName > $arqName.tmp;
rm $arqName;
mv $arqName.tmp $arqName;

echo "Convertendo tudo em caso.dat para minusculas";
sed -e 's/\(.*\)/\L\1/' caso.dat > caso.dat.tmp;
rm caso.dat;
mv caso.dat.tmp caso.dat;

echo "Convertendo tudo em arquivos.dat para minusculas";
sed -e 's/\(.*\)/\L\1/' arquivos.dat > arquivos.dat.tmp;
rm arquivos.dat;
mv arquivos.dat.tmp arquivos.dat;


sed '10s/\(^.\{30\}\).\{3\}/\1'$arqName'/' arquivos.dat -i


echo "Convertendo VAZOES.DAT para minusculas, dentro do arquivo dadger.$arqName";
cat dadger.$arqName | sed -e 's/\(VAZOES.DAT\)/\L\1/g' | sed -e 's/\(POSTOS.DAT\)/\L\1/g' | sed -e 's/\(PREVS\.[A-Z]*\)/\L\1/g' > dadger.$arqName.lower;
rm dadger.$arqName;
mv dadger.$arqName.lower dadger.$arqName;

mv caso.dat caso.dat.tmp
echo "arquivos.dat" > caso.dat

"${gevazpPath}gevazp_L"; rm caso.dat; mv caso.dat.tmp caso.dat;


rm -f *.OUT
rm -f *.out
rm -f GEVAZP.LIC;

echo ""
echo "COTVOL e JUSMED Jirau/Sto Antonio"
/home/compass/sacompass/previsaopld/cpas_ctl_common/scripts/cotvolJIRAUDinamico.sh


/home/compass/sacompass/previsaopld/cpas_ctl_common/scripts/tuctuc.sh






