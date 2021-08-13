#!/bin/bash

INICIO=$(date)
ver=270406


echo -e "\n"
echo "-----------[ Copiando arquivos.nwd ] --------------"
if [[ ! -f arquivos.nwd ]]
then
    cp /home/compass/sacompass/previsaopld/shared/auxiliar/newdesp/arquivos.nwd ./arquivos.nwd
fi





echo -e "\n"
echo "-----------[ Escrevendo caso.dat ] --------------"
rm -f caso.dat
rm -f CASO.DAT
echo "arquivos.nwd" > caso.dat

echo "-----------[ Executando Newdesp 270405 ] --------------"
echo /home/compass/sacompass/previsaopld/shared/install/newave/newave_${ver}/Executaveis/newdesp${ver}_L
/home/compass/sacompass/previsaopld/shared/install/newave/newave_${ver}/Executaveis/newdesp${ver}_L;

rc=$?

FIM=$(date)

echo -e "\n"
echo "Inicio da execucao       $INICIO"
echo "Fim da execucao          $FIM"

exit $rc
