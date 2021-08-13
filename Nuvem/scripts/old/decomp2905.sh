#!/bin/bash

v=2905

par=$1

if [[ "$par" == "tudo" ]]
then
    for folder in $( ls -d */ )
    do
        cd $folder
        
        echo "-------------------------------------------------------------------------------------------------------"
        echo "$( pwd )"
        echo "-------------------------------------------------------------------------------------------------------"
        echo "   "

        echo "/home/compass/sacompass/previsaopld/cpas_ctl_common/scripts/decomp.sh $v";
        /home/compass/sacompass/previsaopld/cpas_ctl_common/scripts/decomp.sh $v;
        ec=$?
        cd ..
        echo "   "
        echo "   "        
    done

    exit $ec;
fi

if [[ "$par" == "preliminar" ]]
then
    echo "/home/compass/sacompass/previsaopld/cpas_ctl_common/scripts/decomp.sh $v nao";
    /home/compass/sacompass/previsaopld/cpas_ctl_common/scripts/decomp.sh $v nao;
    ec=$?
    exit $ec;
fi

echo "/home/compass/sacompass/previsaopld/cpas_ctl_common/scripts/decomp.sh $v";
/home/compass/sacompass/previsaopld/cpas_ctl_common/scripts/decomp.sh $v;
ec=$?    

exit $ec;