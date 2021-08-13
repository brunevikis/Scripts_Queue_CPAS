#!/bin/bash

comm=$1
ign=$2


cluster=$(sed -n 's/^cluster=//p' $comm);
command=$(sed -n 's/^cmd=//p' $comm);

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
    RUNNING[$id]=$( echo "$rs" | grep "${ADDR[$id]}" | wc -l )
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
      if [[ $( check_command ${ADDR[$id]} $command ) == "OK" ]]
      then
        all=$( echo -e "$((  ${RUNNING[$id]} * 100 / ${MAX_PROC[$id]} ))\t${MAX_PROC[$id]}\t${ADDR[$id]}\t${MAX_PROC[$id]}\t${RUNNING[$id]}\n${all}")
      fi
    fi
  done

  echo "$all" | sort -k1,1n -k2,2nr | head -n 1 | cut -f3
}

check_command(){
  _clu=$1
  _cmd=$2
  ssh producao@"$_clu" "if [[ -f \"$_cmd\" ]] ; then echo \"OK\"; else echo \"NOK\"; fi" 
}

read_config;

get_running_procs;



#----test de nova configuracao -- sempre no cluster "B"
if [[ "$cluster" == "null" ]]
then
    echo "OK";
else 

    nCluster="192.168.0.210";    
    sed 's/^\(cluster=\)'"$cluster"'/\1'"$nCluster"'/' "$comm" -i

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


exit 0;


#codigo original

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


