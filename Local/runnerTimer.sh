#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )


while true; do
	
	cd $DIR;
	./runner.sh >> ./runner.log;
	sleep 7;
	
done

