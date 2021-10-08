#!/bin/bash
host=$1

verifica_run=$(grep ^cluster=$host$ /home/compass/queuectl/running/* | cut -f2 -d= | sort)

   for run in $verifica_run; do
	if [ "$run" = "$host" ]
	then
		
		file_queue=$((grep ^cluster=$host$ /home/compass/queuectl/running/* | sort) | cut -f1 -d:)
		PID=$(sed -n 's/^PID=//p' $file_queue);
		dir_caso=$(sed -n 's/^dir=//p' $file_queue);
		echo $PID
		commandname=$(basename "$file_queue")2;
		
		echo ${commandname}
		
		Qcommand="/home/compass/queuectl/queue/$commandname"
		
		echo ${Qcommand}
		
		cp -f $file_queue $Qcommand
		
		#sed '/cluster=/ s/'"$host"'//g' "$Qcommand" -i
		sed '/cluster=/ s/'"$host"'//g' "/home/compass/queuectl/queue/$commandname" -i
		sed '/PID=/d' "$Qcommand" -i
		sed '/STIME=/d' "$Qcommand" -i
		
		
		/home/compass/sacompass/previsaopld/cpas_ctl_common/killer.sh $PID
		
		echo -e "Estudo Cancelado por Indisponibilidade da VM. Estudo será encaminha para fila novamente  \nDiretorio:$dir_caso" | mail -A cpas -s "Estudo Cancelado" pedro.modesto@enercore.com.br,bruno.araujo@enercore.com.br,natalia.biondo@enercore.com.br,thamires.baptista@enercore.com.br
	fi
	done
	