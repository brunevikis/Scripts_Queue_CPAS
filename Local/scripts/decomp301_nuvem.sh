#!/bin/bash

v=301

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


arqName=$( find . -maxdepth 1 -iname caso.dat -exec head -n 1 {} ';' | tr [:upper:] [:lower:] );
if [ -z $arqName ]; then
    echo "arquivo caso.dat nao encontrado ou vazio\n"
    exit 1
fi


echo "-----------[ Convertendo todos os arquivos para minusculas ]-----------";
for i in $( ls -p | grep "/$" -v ); do
    AUXLOWER=`echo $i | tr [:upper:] [:lower:]`;

    if [ ! "$i" == "$AUXLOWER" ]; then
        echo -n "Convertendo $i para $AUXLOWER ... ";
        mv $i $AUXLOWER;
        if [ -f $AUXLOWER ]; then
            echo "ok";
        else
            echo "erro";
        fi
    fi
done

/usr/bin/dos2unix caso.dat;
arqName=$( find . -maxdepth 1 -iname caso.dat -exec head -n 1 {} ';' | tr [:upper:] [:lower:]);
if [ -z $arqName ]; then
    echo "arquivo caso.dat nao encontrado ou vazio\n"
    exit 1
fi



/usr/bin/dos2unix dadger.$arqName;
cat dadger.$arqName | sed 's/CORTES.DAT/cortes.dat/g' | sed 's/CORTESH.DAT/cortesh.dat/g' > dadger.$arqName.lower;
rm dadger.$arqName;
mv dadger.$arqName.lower dadger.$arqName;

cortesPath=$( grep cortes.dat dadger.$arqName | cut -c15-90 )
corteshPath=$( grep cortesh.dat dadger.$arqName | cut -c15-90 )

blocoFC=$( grep "^FC" dadger.$arqName )

linhacortes=$( grep -e "cortes.dat" dadger.$arqName -n | tail -n1 | cut -f1 -d":" )
linhacortesh=$( grep -e "cortesh.dat" dadger.$arqName -n | tail -n1 | cut -f1 -d":" )


origin_dir=$(pwd)
#definir diretorio para processamento  /opt/aplicacoes/newave/arquivo/recebido/$(date +%Y%m%d%H%M%s%N)
work_dir=/mnt/resource/decomp/$(date +%Y%m%d%H%M%s%N)/




if [ ! -f "$cortesPath" ]
then
    echo "Cuts file does not exists"
	exit 6;
fi

echo "-----------[ Copiando deck para pasta de processamento ] --------------"
echo cp -rp "${origin_dir}" "${work_dir}"

cp -rp "${origin_dir}" "${work_dir}"
wait;
cp -p "$cortesPath" "${work_dir}";
wait;
cp -p "$corteshPath" "${work_dir}"
wait;

echo "$cortesPath"

cd "${work_dir}"

sed 's/^FC/\&FC/' dadger.$arqName | sed $linhacortesh'iFC  NEWV21    cortesh.dat\nFC  NEWCUT    cortes.dat' > dadger.$arqName.lower;
rm dadger.$arqName;
mv dadger.$arqName.lower dadger.$arqName;


if [[ "$par" == "preliminar" ]]
then
    echo "/home/compass/sacompass/previsaopld/cpas_ctl_common/scripts/decomp.sh $v nao";
    /home/compass/sacompass/previsaopld/cpas_ctl_common/scripts/decomp.sh $v nao;
    ec=$?
else
	echo "/home/compass/sacompass/previsaopld/cpas_ctl_common/scripts/decomp.sh $v";
	/home/compass/sacompass/previsaopld/cpas_ctl_common/scripts/decomp.sh $v;
	ec=$?    
fi
sed '/^FC/d' dadger.$arqName | sed 's/^\&FC\s/FC /' > dadger.$arqName.lower;
rm dadger.$arqName;
mv dadger.$arqName.lower dadger.$arqName;

rm -f "cortes.dat"
rm -f "cortesh.dat"

cp -f * "${origin_dir}";
wait;
rm -rf ${work_dir};

exit $ec;