#!/bin/bash

v=30

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

        echo "/home/producao/PrevisaoPLD/cpas_ctl_common/scripts/decomp.sh $v";
        /home/producao/PrevisaoPLD/cpas_ctl_common/scripts/decomp.sh $v;
        ec=$?
        cd ..
        echo "   "
        echo "   "        
    done

    exit $ec;
fi

if [[ "$par" == "preliminar" ]]
then
    echo "/home/producao/PrevisaoPLD/cpas_ctl_common/scripts/decomp.sh $v nao";
    /home/producao/PrevisaoPLD/cpas_ctl_common/scripts/decomp.sh $v nao;
    ec=$?
    exit $ec;
fi

echo "/home/producao/PrevisaoPLD/cpas_ctl_common/scripts/gevazp2020.sh";
/home/producao/PrevisaoPLD/cpas_ctl_common/scripts/gevazp2020.sh
echo "/home/producao/PrevisaoPLD/cpas_ctl_common/scripts/decomp.sh $v";
/home/producao/PrevisaoPLD/cpas_ctl_common/scripts/decomp.sh $v nao;
ec=$?    

exit $ec;