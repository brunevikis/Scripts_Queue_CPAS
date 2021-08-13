#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
# echo $DIR;
cd $DIR;

check_node(){
    node=$1
    exitcode=0
    
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
#            ssh $host mount -a nfs &
            ok=0
        elif [ $extCode -eq 1 ] 
        then            
            ok=0
        fi
    done
    
    if [ $ok -eq 0 ]
    then 
        echo "All nodes OK [${2}] NOK"
    else
        echo "All nodes OK [${2}] OK"
    fi
}

echo "Beginning Check"
echo "$(date +%Y-%m-%d\ %T)"

nodelist='192.168.0.211 192.168.0.212 192.168.0.213 192.168.0.214 192.168.0.210 192.168.0.12 192.168.0.13 192.168.0.14 192.168.0.15 192.168.0.16 192.168.0.17 192.168.0.18 192.168.0.19 192.168.0.11'

#192.168.0.15
start_cluster "${nodelist}" "A"
extCode=$?

exit $extCode

