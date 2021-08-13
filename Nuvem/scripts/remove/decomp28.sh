#!/bin/bash

v=28

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

        echo "/home/producao/PrevisaoPLD/cpas_ctl_common/scripts/decomp.sh $v 25";
        /home/producao/PrevisaoPLD/cpas_ctl_common/scripts/decomp.sh $v 25;
        ec=$?
        cd ..
        echo "   "
        echo "   "        
    done

    exit $ec;
fi

if [[ "$par" == "preliminar" ]]
then
    echo "/home/producao/PrevisaoPLD/cpas_ctl_common/scripts/decomp.sh $v 25 nao";
    /home/producao/PrevisaoPLD/cpas_ctl_common/scripts/decomp.sh $v 25 nao;
    ec=$?
    exit $ec;
fi

echo "/home/producao/PrevisaoPLD/cpas_ctl_common/scripts/decomp.sh $v 25";
/home/producao/PrevisaoPLD/cpas_ctl_common/scripts/decomp.sh $v 25;
ec=$?    

exit $ec;