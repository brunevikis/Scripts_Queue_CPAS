#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
while true; do
	
	#echo $DIR;
	cd $DIR;
	./finisher.sh >> ./runner.log;
	sleep 180;
#	inotifywait -t 180 -q -e create,move,modify,delete ./queue/ ./running/ ./finished/ >> ./testCron.log && { sleep 5; ./runner.sh >> ./testCron.log; };
	
done

