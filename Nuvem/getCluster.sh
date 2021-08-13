#!/bin/bash

comm=$1
ign=$2


cluster=$(sed -n 's/^cluster=//p' $comm);
command=$(sed -n 's/^cmd=//p' $comm);


if [[ -n "$( echo $command | grep "killer\.sh" )" ]]
then
  echo "OK";
  exit 0;
fi


read_config() {
  ID=1;
  for c in $( grep -e "^[^#]" ./config )
  do  
    ALIAS[$ID]=$( echo "$c" | cut -f1 -d";" )
    ADDR[$ID]=$( echo "$c" | cut -f2 -d";" )
    MAX_PROC[$ID]=$( echo "$c" | cut -f3 -d";" )
  
    ID=$(( $ID + 1 ))
  done
  
  # echo ${ADDR[@]}

}

get_running_procs() {
  if [ $( ls -A -1 ./running | wc -l ) = 0 ]; then   
    rs=""
  else
    rs=$( grep -e "^cluster=" ./running/* )    
  fi

  
  for id in ${!ADDR[@]}
  do
    RUNNING[$id]=$( echo "$rs" | grep "${ADDR[$id]}$" | wc -l )
  done

  # echo ${RUNNING[@]}
}

all=""

magic() {  
  all=""
  for id in ${!ADDR[@]}
  do
    if [[ ${RUNNING[$id]} -lt ${MAX_PROC[$id]} || $ign == 1 ]]
    then
      if [[ $( check_command_v2 ${ALIAS[$id]} $command ) == "OK" ]]
      then
        all=$( echo -e "$((  ${RUNNING[$id]} * 100 / ${MAX_PROC[$id]} ))\t${MAX_PROC[$id]}\t${ADDR[$id]}\t${MAX_PROC[$id]}\t${RUNNING[$id]}\n${all}")
      fi
    fi
  done

  #echo "$all" | sort -k1,1n -k2,2nr | head -n 1 | cut -f3
  
  ctemp="$( echo "$all" | tail -n 1 | cut -f3 )"  
  
  if [[ -n "${ctemp// }" ]]
  then	  
	  pingResult=$( ping -c 1 -q $ctemp > /dev/null 2>&1; echo $?; )
	 # if [ ! $pingResult -eq 0 ]
	 # then     
		#  echo ""
	  #fi
	  #pingResult=$( ping -c 1 -q $ctemp > /dev/null 2>&1; echo $?; )
	  
	  #status=$(az vm list -d --query "[?name=='$ctemp'].powerState" -o yaml)
	  
	  #if [ "$status" == "- VM running" ]
	  if [ $pingResult -eq 0 ]
	  then            
		  echo "$ctemp"
	  else 
		  echo ""
	  fi  
  else 
	  echo ""
  fi
}

magic_teste() {

  echo "$( date ) ------- $comm = $command"  
  all=""
  for id in ${!ADDR[@]}
  do  
    echo "id = $id - Cod = ${ALIAS[$id]} - Adr= ${ADDR[$id]} - Run = ${RUNNING[$id]} - Max = ${MAX_PROC[$id]}"
    if [[ ${RUNNING[$id]} -lt ${MAX_PROC[$id]} || $ign == 1 ]]
    then
	  echo $( check_command_v2 ${ALIAS[$id]} $command )
      if [[ $( check_command_v2 ${ALIAS[$id]} $command ) == "OK" ]]
      then
	    echo -e "$((  ${RUNNING[$id]} * 100 / ${MAX_PROC[$id]} ))\t${MAX_PROC[$id]}\t${ADDR[$id]}\t${MAX_PROC[$id]}\t${RUNNING[$id]}" 
        all=$( echo -e "$((  ${RUNNING[$id]} * 100 / ${MAX_PROC[$id]} ))\t${MAX_PROC[$id]}\t${ADDR[$id]}\t${MAX_PROC[$id]}\t${RUNNING[$id]}\n${all}" )
      fi
    fi
  done  
  #echo $all >> test2

  ctemp="$( echo "$all" | tail -n 1 | cut -f3 )"  
  
  #por fazor arrumar!!
  if [ "$ctemp" == "10.0.0.4" ]
  then
    ctemp=AZCPSPLDV01
  fi
    if [ "$ctemp" == "10.0.0.6" ]
  then
    ctemp=AZCPSPLDV01-A
  fi
    if [ "$ctemp" == "10.0.0.7" ]
  then
    ctemp=AZCPSPLDV01-B
  fi
  ########
  
  #echo $ctemp >> test2
  
  echo "machinhe - $ctemp"
  if [[ -n "${ctemp// }" ]]  
  then	  
	  echo "$( date ) ------- pinnging $ctemp"
	  pingResult=$( ping -c 1 -q $ctemp > /dev/null 2>&1; echo $?; )
	  if [ ! $pingResult -eq 0 ]
	  then         
		   
		  echo "$( date ) ------- starting $ctemp"     

		  echo sudo -u compass az login --identity --allow-no-subscriptions
		  sudo -u compass az login --identity --allow-no-subscriptions
		  echo sudo -u compass az account set --subscription "Compass"
		  sudo -u compass az account set --subscription "Compass"

		  echo ready	  >> get_cluster.log 2>&1;
		  ready=$( sudo -u compass az vm get-instance-view --resource-group PrevisaoPLD --name $ctemp | grep "\"displayStatus\": \"Ready\"" )
		  echo = $ready
		  if [ -n $ready ]
		  then  
			  echo "-------"
			  echo az vm start --resource-group PrevisaoPLD --name $ctemp
			  sudo -u compass az vm start --resource-group PrevisaoPLD --name $ctemp 
			  echo "-------"
			  echo "$( date ) ------- starting auto power off --- $ctemp"
			  i=0
			 
			  
			  
			  while [ $i -lt 5 ]; do  
				pingResult=$( ping -c 1 -q $ctemp > /dev/null 2>&1; echo $?; )
	          
				if [ $pingResult -eq 0 ]
				then
					#echo Creating folders >> ${ctemp}.log
					#echo "ssh compass@$ctemp \"echo \"$PASSWORD\" | sudo -E -S mkdir -p -m 775 /mnt/resource/{decomp,newave} \"" >> ${ctemp}.log
					#ssh compass@$ctemp "echo \"$PASSWORD\" | sudo -E -S mkdir -pv -m 775 /mnt/resource/{decomp,newave} " >> ${ctemp}.log 2>&1
					( ./autoShutdown.sh $ctemp >> ${ctemp}.log 2>&1 & )
					echo AutoShutdown iniciado >> ${ctemp}.log
					i=11
				else
					i=$(( $i + 1 ))
					sleep 30
				fi
				
			 done
		  
		  fi
      fi  
  
  
	  echo pingResult again
	  pingResult=$( ping -c 1 -q $ctemp > /dev/null 2>&1; echo $?; )
	  if [ $pingResult -eq 0 ]
	  then            
		  echo "$ctemp ready"
	  else 
		  echo "$ctemp not ready"
	  fi
  fi
  
}


check_command_v2(){
 _cluGrp=$( echo $1 | cut -c1 )
 _cmd=$( echo $2 | cut -f1 -d' ' )
 
 if [[ -n $( grep "$_cluGrp:$_cmd" commadAuth ) ]]
 then 
 echo "OK"
 else 
 echo "NOK"
 fi
 
}


read_config;

get_running_procs;



if [[ -n $cluster ]]
then  

  if [[ "$cluster" == "null" ]]
  then
      echo "OK";
  else 
      for id in ${!ADDR[@]}
      do
        if [[ "$cluster" == "${ADDR[$id]}" ]]
        then
          #if [[ ${RUNNING[$id]} -lt ${MAX_PROC[$id]} ]] 
          if [[ ${RUNNING[$id]} -lt ${MAX_PROC[$id]} || $ign == 1 ]]
          then
            echo "OK";
          else
            echo "NOK";
          fi
          break;
        fi
      done
   fi
else    
  magic_teste >> get_cluster.log 2>&1;
  nCluster=$( magic );    
  if [[ -n $nCluster ]]
  then
    sed 's/^\(cluster=\)/\1'"$nCluster"'/' "$comm" -i    
    echo "OK";
  else
    echo "NOK";
  fi
fi

exit 0;


