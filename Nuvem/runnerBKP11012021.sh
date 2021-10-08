#!/bin/bash

PASSWORD="[:X.3LR9@ge_r_*Q"

callback() {
/usr/bin/dotnet /home/compass/sacompass/previsaopld/shared/linuxQueue/LinuxQueueApi/bin/Debug/netcoreapp2.0/LinuxQueueApi.dll "callback" "$1"
}

PLD_Mensal() {
/usr/bin/dotnet /home/compass/sacompass/previsaopld/shared/linuxQueue/LinuxQueueApi/bin/Debug/netcoreapp2.0/LinuxQueueApi.dll "result" "$1"
}

Verifica_Erro(){
#Verifica se o Spot derrubou a Máquina    
	error_spot=$(cat $DIR/run_log/$commandname.run | grep 'port 22: Broken pipe')
	error_host=$(cat $DIR/run_log/$commandname.run | grep 'closed by remote host')
	
	echo "Lendo Erros"
	if [ "$error_spot" == "" ] && [ "$error_host" == "" ]; then
		echo "Nenhum erro encontrado"
	
	else
		rm /home/compass/sacompass/previsaopld/cpas_ctl_common/Status/$CLUSTER
		
		cp $fcommand $command
				
		sed '/cluster=/ s/'"$CLUSTER"'//g' "/home/compass/queuectl/queue/$commandname" -i
		
		sed '/PID=/d' "/home/compass/queuectl/queue/$commandname" -i
		sed '/pldSE=/d' "/home/compass/queuectl/queue/$commandname" -i
		sed '/pldS=/d' "/home/compass/queuectl/queue/$commandname" -i
		sed '/pldNE=/d' "/home/compass/queuectl/queue/$commandname" -i
		sed '/pldN=/d' "/home/compass/queuectl/queue/$commandname" -i
		sed '/EXITCODE=/d' "/home/compass/queuectl/queue/$commandname" -i
		sed '/ETIME=/d' "/home/compass/queuectl/queue/$commandname" -i
		sed '/STIME=/d' "/home/compass/queuectl/queue/$commandname" -i
		
		echo "Erro encontrado"
		#mail -A cpas -s "Load avg $i" pedro.modesto@cpas.com.br,alex.marques@cpas.com.br,bruno.araujo@cpas.com.br,natalia.biondo@cpas.com.br,diana.lima@cpas.com.br < "/home/compass/sacompass/previsaopld/cpas_ctl_common/loadavg/$i"
		#echo -e "$error_spot  $error_host" | mail -A cpas -s "Erro VM" alex.marques@cpas.com.br
	
	fi
	
	ecode=$(sed -n 's/^EXITCODE=//p' /home/compass/queuectl/finished/$commandname);
	dir_caso=$(sed -n 's/^dir=//p' /home/compass/queuectl/finished/$commandname);
	ver_ENCAD=$(cat /home/compass/queuectl/finished/$commandname | grep 'GNL');
	
	if [ "$ver_ENCAD" != "" ]; then
		if [ "$ecode" != "0" ] && [ "$ecode" != "2" ]; then
			echo -e "Caso: $commandname     \nEXITCODE: $ecode \nDiretorio:$dir_caso" | mail -A cpas -s "Erro no Estudo Encadeado" alex.marques@cpas.com.br,bruno.araujo@cpas.com.br,natalia.biondo@cpas.com.br,pedro.modesto@cpas.com.br
		fi
	fi
}

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
#echo "$(date +%Y-%m-%d\ %T) :  $DIR";
cd $DIR;

#get queued comms 
if [ $( ls -A -1 /home/compass/queuectl/queue | wc -l ) = 0 ]; then 
#    echo "$(date +%Y-%m-%d\ %T) : No commmands to run"; 
    exit 1; 
fi


## if none ignoring queue, get by priority
if [ -z "$command" ]
then
  echo "$(date +%Y-%m-%d\ %T) : reading enqueued itens"

br=$'\n'; 
orderedQueue=; 
brr=;

  #echo "$(date +%Y-%m-%d\ %T) : ordering"
  for f in $(ls -1 /home/compass/queuectl/queue); do 
    or=$( sed -n 's/^ord=//p' /home/compass/queuectl/queue/$f );
    or="${or:-99}"; 
    printf -v or "%03d" $or;
    orderedQueue="${orderedQueue}${brr}${or}:${f}"; 
    brr="${brr:-$br}";
  done;   
  
  orderedQueue=$( echo "$orderedQueue" | sort | cut -f2 -d":" );  
   
   
  commandChecked="";
  
  commav=$(comm <(grep ^cluster= /home/compass/queuectl/running/* | cut -f2 -d= | sort) <(cat config | grep -v ^# |cut -f2 -d';'| sort) -1 -3 | sort -n)
  for temp in $commav; do
    t+=("$(grep "$temp;" config | cut -b 1)")
  done
  echo ${t[@]}
  tmp=$t
  for commTemp in $( echo "$orderedQueue" )
  do
  
    cmdChk=$( sed -n 's/^cmd=//p' /home/compass/queuectl/queue/${commTemp} | cut -f1 -d' ' ); 
    x=$(grep $cmdChk commandAuth | cut -b 1)
    n=$(printf '%s\n' ${t[@]} | grep -n -m 1 $x| cut -c 1)
    if [ -z $n ]
    then
        ok=NOK
		nok+=($commTemp);
    else
        t[$(echo $n "- 1" | bc)]="-"
        name=$(echo $commav | cut -d' ' -f $n )
        vm+=("$name")
        #ping=$( ping -c 1 -q $name > /dev/null 2>&1; echo $?; )
        #if [ $ping -eq 0 ]
		if [ -e  "/home/compass/sacompass/previsaopld/cpas_ctl_common/Status/$name" ]
        then
			sed 's/^\(cluster=\)/\1'"$name"'/' "/home/compass/queuectl/queue/$commTemp" -i
            ok="OK"
			commands+=($commTemp);
			break
        else
			echo $name
			if [ -n "$name" ]; then
				ready=$(pgrep -f "Shutdown(2|).sh $name$")
				echo $ready
				if [ -z "$ready" ]; then
					echo "(./autoShutdown.sh $name)"
					(./autoShutdown.sh $name >> ./${name}.log 2>&1 &)
				fi
			fi
            command2+=($commTemp);
            ok=NOK
        fi
    fi
    #if [ -z "$( echo "${commandChecked}" | grep "${cmdChk}"  )" ]
    #then   
    #   commandChecked="${commandChecked}${brr}${cmdChk}";     
    #   ok=OK
    #   #$( ./getCluster.sh "./queue/${commTemp}" )
    #   #echo "./queue/${commTemp}"
       if [[ $ok == "OK" ]]
       then
         commands+=($commTemp);
    #     #echo $commTemp
    #     #break;
       fi
    #fi
  done
     
fi

#echo commands 
echo ${t[@]}
echo commands ${command[@]}
echo command2 ${command2[@]}
echo nok ${nok[@]}
echo ${vm[@]}
#echo $commands

for command in ${commands[@]}
do
echo for $command


if [ -n "$command" ]
then


    command="/home/compass/queuectl/queue/${command}"

    echo "$(date +%Y-%m-%d\ %T) : Running '$command'";
    sleep 0.5;

    if [ ! -f $command ]
    then
        echo "$(date +%Y-%m-%d\ %T) : File not found";
        exit 1;
    fi

    if [ -z $command ]
    then
        echo "$(date +%Y-%m-%d\ %T) : Error, command not supplied";
        exit 1;
    fi

    commandname=$(basename "$command");
    rcommand=/home/compass/queuectl/running/$commandname;
    fcommand=/home/compass/queuectl/finished/$commandname;
    f2command=./fin/$commandname;
    echo "$(date +%Y-%m-%d\ %T) : mv $command $rcommand"
    mv $command $rcommand;
    
        
    WD=$(sed -n 's/^dir=//p' $rcommand);
    echo "$(date +%Y-%m-%d\ %T) : working directory = $WD";
    CMD=$(sed -n 's/^cmd=//p' $rcommand);
    echo "$(date +%Y-%m-%d\ %T) : command = $CMD";
    CLUSTER=$(sed -n 's/^cluster=//p' $rcommand);
    echo "$(date +%Y-%m-%d\ %T) : cluster = $CLUSTER";

    echo "$(date +%Y-%m-%d\ %T) : start running"

    if [[ -n "$( echo $CMD | grep "killer\.sh" )" ]]
    then
        { $CMD > $DIR/run_log/$commandname.run 2>&1; echo "EXITCODE=$?" >> $rcommand; cd $DIR; sleep 2; echo "ETIME=$(date +%Y-%m-%d\ %T)" >> $rcommand; cp $rcommand $f2command; mv $rcommand $fcommand; } & { echo "PID=$!" >> $rcommand; echo "STIME=$(date +%Y-%m-%d\ %T)" >> $rcommand; echo "$(date +%Y-%m-%d\ %T) : PID=$!"; };
    else
	
	  if [ -n "$( echo $WD | grep "/home/producao/" )" ]
	  then	
	    WD=$( ./Sync_L_to_Z.sh "$WD" )
	  fi	
	
      if [ "$CLUSTER" == "AZCPSPLDV02" ]
      then
        ( { cd "$WD" && echo "$PASSWORD" | sudo -E -S $CMD > $DIR/run_log/${commandname}.run 2>&1; echo "EXITCODE=$?" >> $rcommand; cd $DIR; sleep 2; echo "ETIME=$(TZ=":GMT+3" date +%Y-%m-%d\ %T)" >> $rcommand; cp $rcommand $f2command; mv $rcommand $fcommand; callback $commandname; ( cd "$WD" && /home/compass/sacompass/previsaopld/cpas_ctl_common/Sync_Z_to_L.sh ) } & { echo "PID=$!" >> $rcommand; echo "STIME=$(TZ=":GMT+3" date +%Y-%m-%d\ %T)" >> $rcommand; echo "$(TZ=":GMT+3" date +%Y-%m-%d\ %T) : PID=$!"; } );
      else
	    ( { ssh compass@$CLUSTER " cd \"$WD\" && echo \"$PASSWORD\" | sudo -E -S $CMD " > $DIR/run_log/${commandname}.run 2>&1; echo "EXITCODE=$?" >> $rcommand; cd $DIR; sleep 2; echo "ETIME=$(TZ=":GMT+3" date +%Y-%m-%d\ %T)" >> $rcommand; awk -f /home/compass/queuectl/bin/resultados.awk "$WD/dec_oper_sist.csv" >> $rcommand; cp $rcommand $f2command; mv $rcommand $fcommand; callback $commandname; PLD_Mensal $commandname; ( cd "$WD" && /home/compass/sacompass/previsaopld/cpas_ctl_common/Sync_Z_to_L.sh ); Verifica_Erro; } & { echo "PID=$!" >> $rcommand; echo "STIME=$(TZ=":GMT+3" date +%Y-%m-%d\ %T)" >> $rcommand; echo "$(TZ=":GMT+3" date +%Y-%m-%d\ %T) : PID=$!"; } );
      fi      
	fi
	
	
   
 
fi
done

echo "$(date +%Y-%m-%d\ %T) : End runner";

exit 0;


