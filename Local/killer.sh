#!/bin/bash

cmdPid=$1;
command=;
kill_children() #kill in top
{
	ch=$( ps h --ppid $1 o pid );

	if [ -n "$( ps h -p $1 o comm )" ]
	then
		if [ $cmdPid -ne $1 -a -z "$( ps h -p $1 -o comm | grep newave )" ]; #do not kill the runner.sh nor newave(xx)... let it finish naturally		
		then
			echo "kill $1";
			kill $1;
		else
			echo "skip $1";
		fi
	else
		echo "skip $1";
	fi	

	for p in $ch
	do	
		kill_children $p;	
	done
			
}

echo "$(date +%Y-%m-%d\ %T) : Start killer";

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
#echo $DIR;
cd $DIR;

#get first commad to run
for command in $( find ./running -type f -print ); do 

	PID=$( sed -n 's/^PID=//p' $command | tail -n 1 );
	#echo $PID;
	#echo $cmdPid ;	
	#echo $PID;
	#CPID=$( pgrep -P $PID ); # children id
	#echo $CPID;
	
	#echo	"group id = $PGID";

	# se o pid informado foi encontrado rodando, matar tudo;
	if [ "$PID" == "$cmdPid" ]
	then
		echo "$(date +%Y-%m-%d\ %T) : Killing '$command' - pid=$PID";	
			
		if [ -n $( ps h -p $PID -o comm | grep -w runner) ]
		then
			echo "KTIME=$(date +%Y-%m-%d\ %T)" >> $command;
			kill_children $PID;
		fi
	fi	
done



echo "$(date +%Y-%m-%d\ %T) : End killer";

#./finisher.sh &

