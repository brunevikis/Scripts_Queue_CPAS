#!/bin/bash

PASSWORD="[:X.3LR9@ge_r_*Q"

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )



az login --identity --allow-no-subscriptions
az account set --subscription "Compass"


while true; do
	
	cd $DIR;
	echo $PASSWORD | sudo -S ./runner.sh >> ./Logs/runner.log 2>&1;
	sleep 7;
	
done

