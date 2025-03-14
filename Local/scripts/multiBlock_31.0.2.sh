#/bin/bash

    # script para executar diversos decomps em uma pasta, guardando os relatos e possiveis sumarios.

#INICIO=$(date)

#$1 = rvx - pegar do caso.dat
#$2 = #num dadger
 
arqName=$( find . -maxdepth 1 -iname caso.dat -exec head -n 1 {} ';' | tr [:upper:] [:lower:]);

i=$1
if [ -z $i ]
then
    i=1
fi

echo "dadger$i.$arqName"

if [ -f dadger$i.$arqName ]
then
    echo ""
    echo "Executanto iteração $i";

    mv dadger$i.$arqName dadger.$arqName
    wait

    /home/producao/PrevisaoPLD/enercore_ctl_common/scripts/decomp31.0.2.sh preliminar;
    ec=$?

    if [[ "$ec" == 1 ]]
    then
       exit $ec;
    fi



    wait
    mv -f relato.$arqName relato___$i.$arqName
    mv -f sumario.$arqName sumario___$i.$arqName
    mv -f dadger.$arqName dadger___$i.$arqName
    
    echo -e "\n\n\n"
    echo "Concluido iteração $i com sucesso."

    i=$(($i+1))
    sleep 1

    if [ -f dadger$i.$arqName ]
    then

        #agendar próxima iteração
        dt=$(date +%Y%m%d%H%M%S)
        ord=1
        usr="multiblock"
        dir=$( pwd )         
        fn="/home/producao/PrevisaoPLD/enercore_ctl_common/queue/multblock_${i}_${dt}"

        echo "ord=${ord}" > ${fn}
        echo "usr=multiblock" >> ${fn}
        echo "dir=${dir}" >> ${fn}
        echo "cmd=$0 $i" >> ${fn}
        echo "ign=False" >> ${fn}
        echo "cluster=" >> ${fn}
        
    fi

    exit $ec;
fi



