#!/bin/bash

has_defunct=; #global
command=;
defunct_children()
{
	for p in $( ps h --ppid $1 o pid )
	do
		#echo $( ps h -p $p o comm);
		#echo $p;				

		if [ -n "$( ps h -p $p o comm | grep -w defunct )" ]
		then 
			has_defunct="True";
			#echo "$(date +%Y-%m-%d\ %T) : $command is a zombie!!! Killing it!";					
			#echo "KTIME=$(date +%Y-%m-%d\ %T)" >> $command;	
			#kill $1;
		else
			defunct_children $p;
		fi		

	done	
}

#echo "$(date +%Y-%m-%d\ %T) : Start finisher";

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
#echo $DIR;
cd $DIR;

#get first commad to run
for command in $( find ./running -type f -print ); do 

	PID=$( sed -n 's/^PID=//p' $command | tail -n 1 );
	if [ -z $( ps h -p $PID -o comm | grep -w runner) ]
    then
		echo "$(date +%Y-%m-%d\ %T) : $command ( $PID ) isnt running!!! Finishing it!"
		echo "ETIME=$(date +%Y-%m-%d\ %T)" >> $command;
		sleep 1;
		mv $command ./finished/$(basename "$command");
	
	#checkps  if process group has any zombie process
	else #-a $( ps h -p $PID o comm ) == "runner.sh"
		has_defunct=;
		defunct_children $PID;
		if [ $has_defunct ] 
		then 

			echo "$(date +%Y-%m-%d\ %T) : Maybe the $command is a zombie, will check again in a moment.";
			has_defunct=;
			sleep 60;
			#wait and check again make sure the defunct state isn't temporary. (NWLISTOP issue) 
			defunct_children $PID;
			if [ $has_defunct ] 
			then
				echo "$(date +%Y-%m-%d\ %T) : $command is a zombie!!! Killing it!";
				echo "KTIME=$(date +%Y-%m-%d\ %T)" >> $command;
				./killer.sh $PID;
			fi
		fi
	fi
done



#check if timer is running
if [ -z $( pgrep -f 'runnerTimer.sh') ]; then


    ./checkNode_ReadOnly.sh
    extCode=$?
	
	if [ $extCode -eq 0 ] 
    then            
    	echo "$(date +%Y-%m-%d\ %T) : Timer not running...starting it now";
	   ./runnerTimer.sh &
	else
	    echo "$(date +%Y-%m-%d\ %T) : HPC not ready";  
    fi


fi

#echo "$(date +%Y-%m-%d\ %T) : End finisher";

#clear keep log small
tail -n 10000 runner.log > runner.log.tmp;
cat runner.log.tmp > runner.log;
rm runner.log.tmp;



