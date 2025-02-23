#!/bin/bash
# script para execucao do gevazp
v=$1
/usr/bin/dos2unix caso.dat;
arqName=$( find . -maxdepth 1 -iname caso.dat -exec head -n 1 {} ';' | tr "[:upper:]" "[:lower:]");
if [[ ! -f "prevs.$arqName" ]]; then
    echo -e "-----------[**********  ERRO - PREVS.$arqName NÃO ENCONTRADO   **********]-----------\n";
    exit 8
fi

gevazpPath="/home/producao/PrevisaoPLD/shared/gevazp/$v/"

echo "-----------[ Convertendo todos os arquivos para minusculas ]-----------";
for i in *; do
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
echo "$arqName"
/usr/bin/dos2unix "$arqName";
cp "${gevazpPath}gevazp.lic" ./gevazp.lic
[ ! -f modif.dat ] && cp "${gevazpPath}modif.dat" ./modif.dat
[ ! -f regras.dat  ] && cp "${gevazpPath}regras.dat" ./regras.dat
[ ! -f postos.dat  ] && cp "${gevazpPath}postos.dat" ./postos.dat
[ ! -f gevazp.dat  ] && cp "${gevazpPath}gevazp.dat" ./gevazp.dat
[ ! -f arquivos.dat  ] && cp "${gevazpPath}arquivos.dat" ./arquivos.dat
/usr/bin/dos2unix arquivos.dat;

#echo -e "-----------[ Executando ConverteNomesArquivosDecomp ]-----------\n";
#/opt/aplicacoes/decomp/bin/convertenomesdecomp_30;
echo "Convertendo tudo em $arqName para minusculas";
sed -i 's/\(.*\)/\L\1/' "$arqName"
echo "Convertendo tudo em caso.dat para minusculas";
sed -i 's/\(.*\)/\L\1/' caso.dat
echo "Convertendo tudo em arquivos.dat para minusculas";
sed -i 's/\(.*\)/\L\1/' arquivos.dat
sed '10s/\(^.\{30\}\).\{3\}/\1'"$arqName"'/' arquivos.dat -i


echo "Convertendo VAZOES.DAT para minusculas, dentro do arquivo dadger.$arqName";
#sed -e 's/\(VAZOES.DAT\)/\L\1/g' "dadger.$arqName" | sed -e 's/\(POSTOS.DAT\)/\L\1/g' | sed -e 's/\(PREVS\.[A-Z]*\)/\L\1/g' > "dadger.$arqName.lower";
sed -e 's/\(VAZOES.DAT\)/\L\1/g;s/\(POSTOS.DAT\)/\L\1/g;s/\(PREVS\.[A-Z]*\)/\L\1/g;s/\(PREVSVEL\.[A-Z]*\)/\L\1/g' "dadger.$arqName" > "dadger.$arqName.lower"
rm "dadger.$arqName";
mv "dadger.$arqName.lower" "dadger.$arqName";
mv caso.dat caso.dat.tmp
echo "arquivos.dat" > caso.dat
echo "Executando gevazp $v";
if [ -f "${gevazpPath}gevazp_L" ]; then
  "${gevazpPath}gevazp_L";
  err=$?
fi
if [ -f "${gevazpPath}gevazp" ]; then
  "${gevazpPath}gevazp";
  err=$?
fi
rm caso.dat;
mv caso.dat.tmp caso.dat;
rm -f ./*.OUT
rm -f ./*.out
rm -f GEVAZP.LIC;
rm -f gevazp.lic;
rm -f *.rel;
[ $err -ne 0 ] && exit $err
[ -f gevazp.err ] && exit 3
echo ""
#echo "COTVOL e JUSMED Jirau/Sto Antonio"
#/home/producao/PrevisaoPLD/enercore_ctl_common/scripts/cotvolJIRAUDinamico.sh
/home/producao/PrevisaoPLD/enercore_ctl_common/scripts/tuctuc.sh