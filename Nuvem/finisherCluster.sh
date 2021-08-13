#!/bin/bash

has_defunct=; #global
command=;
defunct_children()
{
    for p in $( ps h --ppid $1 o pid )
    do
        if [ -n "$( ps h -p $p o comm | grep -w defunct )" ]
        then 
            has_defunct="True";
        else
            defunct_children $p;
        fi        
    done    
}

for PID in $( ps -u producao | grep mpiexec | cut -f1 -d'?' ); do 
        has_defunct=;
        defunct_children $PID;
        if [ $has_defunct ] 
        then 

            echo "$(date +%Y-%m-%d\ %T) : Maybe the $command is a zombie, will check again in a moment.";
            has_defunct=;
            sleep 60;
            #wait and check again make sure the defunct state isn't temporary. (NWLISTOP issue) 
            defunct_children $PID;
            if [ $has_defunct ] 
            then
                echo "$(date +%Y-%m-%d\ %T) : $command is a zombie!!! Killing it!";
                kill -9 $PID;
            fi
        fi
done



