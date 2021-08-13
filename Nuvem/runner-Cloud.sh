#!/bin/bash

PASSWORD="[:X.3LR9@ge_r_*Q"

callback() {
/usr/bin/dotnet /home/compass/sacompass/previsaopld/shared/linuxQueue/LinuxQueueApi/bin/Release/netcoreapp2.0/LinuxQueueApi.dll "callback" "$1"
}
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
#echo "$(date +%Y-%m-%d\ %T) :  $DIR";
cd $DIR;

#get queued comms 
if [ $( ls -A -1 ./queue | wc -l ) = 0 ]; then 
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
  for f in $(ls -1 ./queue); do 
    or=$( sed -n 's/^ord=//p' ./queue/$f );     
    or="${or:-99}"; 
    printf -v or "%03d" $or;
    orderedQueue="${orderedQueue}${brr}${or}:${f}"; 
    brr="${brr:-$br}";
  done;   
  
  orderedQueue=$( echo "$orderedQueue" | sort | cut -f2 -d":" );  
   
   
  commandChecked="";
  
  commav=$(comm <(grep ^cluster= running/* | cut -f2 -d= | sort) <(cat config | grep -v ^# |cut -f2 -d';'| sort) -1 -3)
  for temp in $commav; do
    t+=("$(grep "$temp;" config | cut -b 1)")
  done
  echo ${t[@]}
  tmp=$t
  for commTemp in $( echo "$orderedQueue" )
  do
  
    cmdChk=$( sed -n 's/^cmd=//p' ./queue/${commTemp} | cut -f1 -d' ' ); 
    x=$(grep $cmdChk commadAuth | cut -b 1)
    n=$(printf '%s\n' ${t[@]} | grep -n -m 1 $x| cut -c 1)
	echo $cmdChk x $x n $n
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
		if [ -e  "/home/compass/sacompass/previsaopld/cpas_ctl_common/$name" ]
        then
			sed 's/^\(cluster=\)/\1'"$name"'/' "./queue/$commTemp" -i
            ok="OK"
        else
			echo $name
			if [ -n "$name" ]; then
				ready=$(pgrep -f "Shutdown.sh $name$")
				echo $ready
				if [ -z "$ready" ]; then
					echo "(./autoShutdown.sh $name)"
					(./autoShutdown.sh $name >> ${name}.log 2>&1 &)
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


    command="./queue/${command}"

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
    rcommand=./running/$commandname;
    fcommand=./finished/$commandname;
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
        { $CMD > $DIR/run_log/$commandname.run 2>&1; echo "EXITCODE=$?" >> $DIR/$rcommand; cd $DIR; sleep 2; echo "ETIME=$(date +%Y-%m-%d\ %T)" >> $rcommand; cp $rcommand $f2command; mv $rcommand $fcommand; } & { echo "PID=$!" >> $rcommand; echo "STIME=$(date +%Y-%m-%d\ %T)" >> $rcommand; echo "$(date +%Y-%m-%d\ %T) : PID=$!"; };
    elif [ "$CLUSTER" == "AZCPSPLDV02" ]
    then
        ( { cd "$WD" && echo "$PASSWORD" | sudo -E -S $CMD > $DIR/run_log/${commandname}.run 2>&1; echo "EXITCODE=$?" >> $DIR/$rcommand; cd $DIR; sleep 2; echo "ETIME=$(TZ=":GMT+3" date +%Y-%m-%d\ %T)" >> $rcommand; cp $rcommand $f2command; mv $rcommand $fcommand; callback $commandname; } & { echo "PID=$!" >> $rcommand; echo "STIME=$(TZ=":GMT+3" date +%Y-%m-%d\ %T)" >> $rcommand; echo "$(TZ=":GMT+3" date +%Y-%m-%d\ %T) : PID=$!"; } );
    else
    #( { ssh compass@$CLUSTER " cd \"$WD\" && echo \"$PASSWORD\" | sudo -S $CMD " > $DIR/run_log/$commandname.run 2>&1; echo "EXITCODE=$?" >> $DIR/$rcommand; cd $DIR; sleep 2; echo "ETIME=$(date +%Y-%m-%d\ %T)" >> $rcommand; mv $rcommand $fcommand; } & { echo "PID=$!" >> $rcommand; echo "STIME=$(date +%Y-%m-%d\ %T)" >> $rcommand; echo "$(date +%Y-%m-%d\ %T) : PID=$!"; } );
    ( { ssh compass@$CLUSTER " cd \"$WD\" && echo \"$PASSWORD\" | sudo -E -S $CMD " > $DIR/run_log/${commandname}.run 2>&1; echo "EXITCODE=$?" >> $DIR/$rcommand; cd $DIR; sleep 2; echo "ETIME=$(TZ=":GMT+3" date +%Y-%m-%d\ %T)" >> $rcommand; cp $rcommand $f2command; mv $rcommand $fcommand; callback $commandname; } & { echo "PID=$!" >> $rcommand; echo "STIME=$(TZ=":GMT+3" date +%Y-%m-%d\ %T)" >> $rcommand; echo "$(TZ=":GMT+3" date +%Y-%m-%d\ %T) : PID=$!"; } );
    #( { ssh compass@$CLUSTER " cd \"$WD\" && echo \"$PASSWORD\" | sudo -E -S $CMD " > $DIR/run_log/${commandname}.run ; echo "EXITCODE=$?" >> $DIR/$rcommand; cd $DIR; sleep 2; echo "ETIME=$(date +%Y-%m-%d\ %T)" >> $rcommand; mv $rcommand $fcommand; } & { echo "PID=$!" >> $rcommand; echo "STIME=$(date +%Y-%m-%d\ %T)" >> $rcommand; echo "$(date +%Y-%m-%d\ %T) : PID=$!"; } );
    
    
    #   ( { ssh compass@$CLUSTER " cd \"$WD\" && echo \"$PASSWORD\" | sudo -S $CMD " > $DIR/run_log/$commandname.run 2>&1; cd $DIR; sleep 2; mv $rcommand $fcommand; } & { echo "$(date +%Y-%m-%d\ %T) : PID=$!"; } );  
    fi
   
 
fi
done

echo "$(date +%Y-%m-%d\ %T) : End runner";

exit 0;
