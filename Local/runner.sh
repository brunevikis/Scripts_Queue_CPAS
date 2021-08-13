#!/bin/bash


callback() {
/usr/bin/dotnet /home/producao/PrevisaoPLD/shared/linuxQueue/LinuxQueueApi/bin/Release/netcoreapp2.0/LinuxQueueApi.dll "callback" "$1"
}

#echo "$(date +%Y-%m-%d\ %T) : Start runner";

#exit 0;

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
#echo "$(date +%Y-%m-%d\ %T) :  $DIR";
cd $DIR;


#get queued comms 
if [ $( ls -A -1 ./queue | wc -l ) = 0 ]; then 
#    echo "$(date +%Y-%m-%d\ %T) : No commmands to run"; 
    exit 1; 
fi

used=$( df | grep /home/producao/PrevisaoPLD | cut -c53-54 )
if [[ $used > 96 ]]
then  
 echo "Alerta de DISCO L: cheio"
 #exit 1;
fi

command=;
#echo "$(date +%Y-%m-%d\ %T) : check for ign flaged comms"
#for f in $(ls -1 ./queue); do    
#    IGN=$( sed -n 's/^ign=//p' ./queue/$f );
#    if [ $IGN == "True" ]; then 
#        echo "$(date +%Y-%m-%d\ %T) : $f Ignoring queue and running"; 
#
#        ok=$( ./getCluster.sh "./queue/${f}" 1 )
#        if [[ $ok == "OK" ]]
#        then
#            command=$f;
#            break;
#        fi
#    fi
#done

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
   
  for commTemp in $( echo "$orderedQueue" )
  do
    cmdChk=$( sed -n 's/^cmd=//p' ./queue/${commTemp} | cut -f1 -d' ' ); 
    
    if [ -z "$( echo "${commandChecked}" | grep "${cmdChk}"  )" ]
    then   
       commandChecked="${commandChecked}${brr}${cmdChk}";     
       ok=$( ./getCluster.sh "./queue/${commTemp}" )
       #echo "./queue/${commTemp}"
       if [[ $ok == "OK" ]]
       then
         command=$commTemp;
         break;
       fi     
    fi
  done
     
fi

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
        { $CMD > $DIR/run_log/$commandname.run 2>&1; echo "EXITCODE=$?" >> $DIR/$rcommand; cd $DIR; sleep 2; echo "ETIME=$(date +%Y-%m-%d\ %T)" >> $rcommand; mv $rcommand $fcommand; callback $commandname;  } & { echo "PID=$!" >> $rcommand; echo "STIME=$(date +%Y-%m-%d\ %T)" >> $rcommand; echo "$(date +%Y-%m-%d\ %T) : PID=$!"; };
    #elif [[ -n "$( echo $CMD | grep "previvaz3\.sh" )" ]]
    #then
    #    ( { cd "$WD" && $CMD                             > $DIR/run_log/$commandname.run 2>&1; echo "EXITCODE=$?" >> $DIR/$rcommand; cd $DIR; sleep 2; echo "ETIME=$(date +%Y-%m-%d\ %T)" >> $rcommand; mv $rcommand $fcommand;  #} & { echo "PID=$!" >> $rcommand; echo "STIME=$(date +%Y-%m-%d\ %T)" >> $rcommand; echo "$(date +%Y-%m-%d\ %T) : PID=$!"; } );
    elif [ "$CLUSTER" == "null" -o "$CLUSTER" == "192.168.0.10" -o "$CLUSTER" == "local" ]
    then
        ( { cd "$WD" && $CMD                             > $DIR/run_log/$commandname.run 2>&1; echo "EXITCODE=$?" >> $DIR/$rcommand; cd $DIR; sleep 2; echo "ETIME=$(date +%Y-%m-%d\ %T)" >> $rcommand; mv $rcommand $fcommand; callback $commandname;  } & { echo "PID=$!" >> $rcommand; echo "STIME=$(date +%Y-%m-%d\ %T)" >> $rcommand; echo "$(date +%Y-%m-%d\ %T) : PID=$!"; } );    
    else
        ( { ssh producao@$CLUSTER " cd \"$WD\" && $CMD " > $DIR/run_log/$commandname.run 2>&1; echo "EXITCODE=$?" >> $DIR/$rcommand; cd $DIR; sleep 2; echo "ETIME=$(date +%Y-%m-%d\ %T)" >> $rcommand; mv $rcommand $fcommand; callback $commandname;  } & { echo "PID=$!" >> $rcommand; echo "STIME=$(date +%Y-%m-%d\ %T)" >> $rcommand; echo "$(date +%Y-%m-%d\ %T) : PID=$!"; } );
    fi
   
 
fi

echo "$(date +%Y-%m-%d\ %T) : End runner";

exit 0;
