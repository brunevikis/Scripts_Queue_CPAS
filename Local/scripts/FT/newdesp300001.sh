#!/bin/bash

INICIO=$(date)
ver=300001


echo -e "\n"
echo "-----------[ Copiando arquivos.nwd ] --------------"
if [[ ! -f arquivos.nwd ]]
then
    cp /home/producao/PrevisaoPLD/shared/auxiliar/newdesp/arquivos.nwd ./arquivos.nwd
fi





echo -e "\n"
echo "-----------[ Escrevendo caso.dat ] --------------"
rm -f caso.dat
rm -f CASO.DAT
echo "arquivos.nwd" > caso.dat

echo "-----------[ Executando Newdesp 280003 ] --------------"
echo /home/producao/PrevisaoPLD/shared/install/newave/newave_${ver}/Executaveis/newdesp${ver}
/home/producao/PrevisaoPLD/shared/install/newave/newave_${ver}/Executaveis/newdesp${ver};

rc=$?

FIM=$(date)

echo -e "\n"
echo "Inicio da execucao       $INICIO"
echo "Fim da execucao          $FIM"

exit $rc
