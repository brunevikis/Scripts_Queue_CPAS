#!/bin/bash

iddleCount=0
PASSWORD="[:X.3LR9@ge_r_*Q"

host=$1
echo $host

 
#name=$( echo $host | cut -f1 -d' ' ) 

#host+=( $( host $host | awk '/has address/ { print $4 }' ))

echo "Iniciando"


Start(){

  ########
  
  #echo $ctemp >> test2
  echo "Iniciando Start"
  echo "machinhe - $host"
  
	

	echo Teste de Status
	status=$(az vm list -d --query "[?name=='$host'].powerState" -o yaml | cut -f3 -d" ")

		  
	echo $status
	if [ "$status" = "deallocated" ]
	  then         
		   
		  echo "$( date ) ------- starting $host"     

		  echo sudo -u compass az login --identity --allow-no-subscriptions
		  sudo -u compass az login --identity --allow-no-subscriptions
		  echo sudo -u compass az account set --subscription "Compass"
		  sudo -u compass az account set --subscription "Compass"
		  
		  echo "-------"
		  echo az vm start --resource-group PrevisaoPLD --name $host
		  sudo -u compass az vm start --resource-group PrevisaoPLD --name $host 
		  echo "-------"  
		  
		status=$(az vm list -d --query "[?name=='$host'].powerState" -o yaml | cut -f3 -d" ")
		
		if [ "$status" != "deallocated" ]
		then
			while [ "$status" != "running" ]
			do
			sleep 10	
			status=$(az vm list -d --query "[?name=='$host'].powerState" -o yaml | cut -f3 -d" ")
			done
			Status_SSH=false
			echo Creating folders >> ${host}.log
			echo "ssh compass@$ctemp \"echo \"$PASSWORD\" | sudo -E -S mkdir -p -m 775 /mnt/resource/{decomp,newave} | sudo -E -S mkdir -p -m 775 /dev/shm/{decomp,newave} \"" >> ${host}.log
			#ssh compass@$host "echo \"$PASSWORD\" | sudo -E -S mkdir -pv -m 775 /mnt/resource/{decomp,newave} && touch /home/compass/sacompass/previsaopld/cpas_ctl_common/$(hostname)"  
			
	
			while [ ! -e  "/home/compass/sacompass/previsaopld/cpas_ctl_common/Status/$host" ]
			do
				echo "SSH Falhou"
				sleep 20
				#ssh compass@$host "echo \"$PASSWORD\" " && Status_SSH=true
				ssh compass@$host "echo \"$PASSWORD\" | sudo -E -S mkdir -p -m 775 /dev/shm/{decomp,newave} && touch /home/compass/sacompass/previsaopld/cpas_ctl_common/Status/$host" 
				ssh compass@$host "echo \"$PASSWORD\" | sudo -E -S mkdir -pv -m 775 /mnt/resource/{decomp,newave} && touch /home/compass/sacompass/previsaopld/cpas_ctl_common/Status/$host" 
				ssh compass@$host "echo \"$PASSWORD\" | sudo -E -S mount -a" 
			done
			
			echo "Criou Pasta "
		fi
	else
		echo "Vm $status"
	fi  	
}



count_running(){
RUNNING=0
 
if [ $( ls -A -1 /home/compass/queuectl/running | wc -l ) = 0 ]; then   
rs=""
else
rs=$( grep -e "^cluster=" /home/compass/queuectl/running/* )    
fi
 
for id in ${host[@]}
do
temp=$( echo "$rs" | grep "${id}\$" | wc -l )
RUNNING=$(( $RUNNING + $temp ))
done

echo $RUNNING

}


Start

if [ "$status" = "running" ]
then  
	while [ $iddleCount -lt 15 ] && [ "$status" != "deallocated" ]; do
		# && [ "$status" = "running" ]
		#cd $DIR;
		#echo $PASSWORD | sudo -S ./runner.sh >> ./runner.log;
		
		sleep 60;
		
		if [ $( count_running ) -eq 0 ]; then
			iddleCount=$(( $iddleCount + 1 ))	
			echo "$( date ) -  Iddle"	
		else
			iddleCount=0
			echo "$( date ) - Not Iddle"
		fi
		status=$(az vm list -d --query "[?name=='$host'].powerState" -o yaml | cut -f3 -d" ")
		
	done
	rm  -f "/home/compass/sacompass/previsaopld/cpas_ctl_common/Status/$host"
	status=$(az vm list -d --query "[?name=='$host'].powerState" -o yaml | cut -f3 -d" ")
          
	echo "Shutting down"

	if [ "$status" != "deallocated" ]
	then
		echo az login --identity --allow-no-subscriptions 
		sudo -u compass az login --identity --allow-no-subscriptions 
		echo az account set --subscription "Compass" 
		sudo -u compass az account set --subscription "Compass" 
		echo az vm stop --resource-group PrevisaoPLD --name $host
		sudo -u compass az vm stop --resource-group PrevisaoPLD --name $host
		echo az vm deallocate --resource-group PrevisaoPLD --name $host
		sudo -u compass az vm deallocate --resource-group PrevisaoPLD --name $host
		
		rm -f "/home/compass/sacompass/previsaopld/cpas_ctl_common/loadavg/$host"
	else
		rm -f "/home/compass/sacompass/previsaopld/cpas_ctl_common/loadavg/$host"
		sleep 300
		
	fi
	
fi
