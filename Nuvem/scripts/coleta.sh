#!/bin/bash
echo "sep=;" > pld.csv
echo "caso;submercado;CMO;PLD;earm" >> pld.csv
find "$(pwd)" -iname "dec_oper_sist.csv" | xargs -I{} awk -v x="$(pwd)/" -f /home/compass/queuectl/bin/coleta.awk "{}" >> pld.csv
find "$(pwd)" -iname "dec_oper_sist.csv" | xargs -I{} bash -c 'echo "{}"|cut -d'/' -f6- && awk -f /home/compass/queuectl/pld.awk "{}"'
