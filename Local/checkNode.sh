#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
# echo $DIR;
cd $DIR;

check_node(){
    node=$1
    exitcode=0
    
    #echo -e "Checking server $node...\c"
    
    pingResult=$( ping -c 1 -q $node > /dev/null 2>&1; echo $?; )
    
    if [ ! $pingResult -eq 0 ]
    then            
        exitcode=1
    else
        fsCount=$( ssh $node "cat /etc/fstab" | grep -e '^192' | wc -l )
        dfCount=$( ssh $node "df" | grep -e '^192' | wc -l )
    
        if [ $fsCount -gt $dfCount ]    
        then            
            exitcode=2
        #else
        #    echo "OK"
        fi
    fi
    
    return $exitcode
}

start_cluster(){
    
    ok=1
    for host in ${1}
    do        
        check_node $host
        extCode=$?
                
        if [ $extCode -eq 2 ] 
        then
            echo "File system on $node not mounted properly, trying to mount." 
            ssh $host mount -a nfs &
            ok=0
        elif [ $extCode -eq 1 ] 
        then
            echo "Server $host not responding!"
            ok=0
        fi
    done
    
    if [ $ok -eq 0 ]
    then 
        echo "Cluster ${2} NOK"
    else
        echo "Cluster ${2} OK"
    fi
}

echo "Beginning Check"
echo "$(date +%Y-%m-%d\ %T)"

clusterB='192.168.0.211 192.168.0.212 192.168.0.213 192.168.0.214 192.168.0.210'
clusterC='192.168.0.12 192.168.0.13 192.168.0.14 192.168.0.15 192.168.0.16 192.168.0.17 192.168.0.18 192.168.0.19 192.168.0.11'
#192.168.0.15
start_cluster "${clusterB}" "B"
start_cluster "${clusterC}" "C"

echo ""

#clear keep log small
tail -n 10000 chkClusters.log > chkClusters.log.tmp;
cat chkClusters.log.tmp > chkClusters.log;
rm chkClusters.log.tmp;





used=$( df | grep /home/producao/PrevisaoPLD | cut -c53-54 )
if [[ $used > 95 ]]
then  
 echo "$used% usados" | mailx -v -A gmail -s verbose=1 -s "Alerta de DISCO L: cheio" bruno.araujo@cpas.com.br, alex.marques@cpas.com.br, pedro.modesto@cpas.com.br
fi

exit 0