#!/bin/bash

INICIO=$(date)
ver=281501

echo -e "\n"
echo "-----------[ Copiando arquivos.nwc/nwlistcf.dat ] --------------"
if [[ ! -f arquivos.nwc ]]
then
    cp /home/producao/PrevisaoPLD/shared/auxiliar/nwlistcf/arquivos.nwc ./arquivos.nwc
fi

if [[ ! -f nwlistcf.dat ]]
then
    cp /home/producao/PrevisaoPLD/shared/auxiliar/nwlistcf/nwlistcf.dat ./nwlistcf.dat
fi


echo -e "\n"
echo "-----------[ Escrevendo caso.dat ] --------------"
rm -f caso.dat
rm -f CASO.DAT
echo "arquivos.nwc" > caso.dat

zipok=""
echo "-----------[ Descompactando cortese.dat ] --------------"
if [[ -f cortese.zip ]]
then
    rm -f cortese.dat;
    unzip cortese && zipok="OK";
elif [[ -f cortese.dat ]]
then
    zip cortese cortese.dat && zipok="OK";
else
    echo "Arquivo cortese.dat n�o encontrado"
    exit 1;
fi

echo "-----------[ Executando Nwlistcf 280003 ] --------------"
echo /home/producao/PrevisaoPLD/shared/install/newave/newave_${ver}/Executaveis/nwlistcf${ver}_L
/home/producao/PrevisaoPLD/shared/install/newave/newave_${ver}/Executaveis/nwlistcf${ver}_L;
rc=$?

if [[ $zipok == "OK" ]] 
then
    rm -f cortese.dat;
fi

FIM=$(date)

echo -e "\n"
echo "Inicio da execucao       $INICIO"
echo "Fim da execucao          $FIM"

exit $rc
