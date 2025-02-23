#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )


while true; do
	
	cd $DIR;
	./runner.sh >> ./Logs/runner.log 2>&1;
	sleep 7;
	
done

