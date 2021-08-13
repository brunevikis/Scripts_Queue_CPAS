#!/bin/bash

ctemp='AZCPSPLDV01'

echo Teste de Status
#status=$(az vm list -d --query "[?name=='$ctemp'].powerState")
status='teste'		  
if [ $status == "VM running" ]
then
	echo Maquina Rodando
else
	echo Status Maquina $status
fi
exit 0

