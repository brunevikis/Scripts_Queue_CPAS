#!/bin/bash

INICIO=$(date)
ver=281106


echo "-----------[ Copiando nwlistop.dat ] --------------"
if [ ! -f "nwlistop.dat" -o "$1" == "all" ]
then
	echo "Nwlistop.dat não encontrado, copiando nwlistop.dat default"
	echo "/home/producao/PrevisaoPLD/shared/auxiliar/nwlistop/nwlistop.dat"
    cp /home/producao/PrevisaoPLD/shared/auxiliar/nwlistop/nwlistop.dat ./nwlistop.dat

    numAnosL=$(sed '4!d' dger.dat);
    numAnos=${numAnosL:23:2};
    mesIniL=$(sed '6!d' dger.dat);
    mesIni=${mesIniL:23:2};
    perFim=$(( ${numAnos}* 12 - ${mesIni} + 1));
    sed '7s/\(^.\{5\}\).\{3\}/\1'${perFim}' /' nwlistop.dat -i;
fi



zipok=""
echo "-----------[ Descompactando forward.dat ] --------------"
if [[ -f forward.zip ]]
then
    rm -f forwad.dat;
wait;
    unzip forward && zipok="OK";
wait;
elif [[ -f forward.dat ]]
then
    zip forward forward.dat && zipok="OK";
else
    echo "Arquivo forward.dat não encontrado"
    exit 1;
fi

rm -f fort.4
rm -f *.out
wait;

echo "-----------[ Executando Nwlistop 280003 ] --------------"
echo "/home/producao/PrevisaoPLD/shared/install/newave/newave_${ver}/Executaveis/nwlistop${ver}_L"
/home/producao/PrevisaoPLD/shared/install/newave/newave_${ver}/Executaveis/nwlistop${ver}_L;
rc=$?

if [[ $zipok == "OK" ]] 
then
    rm -f forward.dat;
fi


if [[ -f fort.4 ]]
then
    echo ""
    cat fort.4
    rc=13
fi


FIM=$(date)

echo -e "\n"
echo "Inicio da execucao       $INICIO"
echo "Fim da execucao          $FIM"

exit $rc
