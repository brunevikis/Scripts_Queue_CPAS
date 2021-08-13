#!/bin/bash

v=301

par=$1

#PASSWORD="[:X.3LR9@ge_r_*Q"
#echo "$PASSWORD"

#echo $( pwd )

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

cortesPath=$( grep cortes.dat dadger.$arqName | cut -c15-200 )
corteshPath=$( grep cortesh.dat dadger.$arqName | cut -c15-200 )


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
#if [ $ec == 0 -o $ec == 7 ]
if [ $ec == 0 -o $ec == 7 -o $ec == 5 ]
then
 arq=$( cat caso.dat ) 
 if [ ! -f "sumario.$arq" ]
 then 

   echo ""
   echo "Removendo Inviabilidades"
   
   rm -f relato.bkp
   cp -pf ./relato.* ./relato.bkp   
   
   dotnet "/home/compass/sacompass/previsaopld/shared/price_tools/inviab/bin/Release/netcoreapp2.0/TrataInviab.dll" 1
   /usr/bin/dotnet /home/compass/sacompass/previsaopld/shared/price_tools/inviab/bin/Debug/netcoreapp2.0/TrataInviab.dll "flexTucurui"
   
   echo "/home/compass/sacompass/previsaopld/cpas_ctl_common/scripts/decomp.sh $v nao";
   /home/compass/sacompass/previsaopld/cpas_ctl_common/scripts/decomp.sh $v nao;
   ec=$?   
   
   if [ ! -f "sumario.$arq" ]
   then    
   
     echo ""
     echo "Removendo Inviabilidades - segunda iteracao"
   
     rm -f relato.bkp
     cp -pf ./relato.* ./relato.bkp 
	 
	 dotnet "/home/compass/sacompass/previsaopld/shared/price_tools/inviab/bin/Release/netcoreapp2.0/TrataInviab.dll" 3
	 /usr/bin/dotnet /home/compass/sacompass/previsaopld/shared/price_tools/inviab/bin/Debug/netcoreapp2.0/TrataInviab.dll "flexTucurui"
	 
	 echo "/home/compass/sacompass/previsaopld/cpas_ctl_common/scripts/decomp.sh $v nao";
     /home/compass/sacompass/previsaopld/cpas_ctl_common/scripts/decomp.sh $v nao;
     ec=$?    
   
     #Continua nao convergindo
     if [ ! -f "sumario.$arq" ]
     then
       echo "  !!!!!!!!!!!!!!!!!!!!!!  "
       echo "  falha na convergencia   "
     echo "  !!!!!!!!!!!!!!!!!!!!!!  "
     ec=2        
     fi   
   fi      
  fi
fi


if [ ! -f "sumario.$arq" ]
then
  echo "  !!!!!!!!!!!!!!!!!!!!!!  "
  echo "  falha na convergencia   "
echo "  !!!!!!!!!!!!!!!!!!!!!!  "
ec=2        
fi   

sed '/^FC/d' dadger.$arqName | sed 's/^\&FC\s/FC /' > dadger.$arqName.lower;
rm dadger.$arqName;
mv dadger.$arqName.lower dadger.$arqName;

rm -f "cortes.dat"
rm -f "cortesh.dat"

cp -f * "${origin_dir}";
wait;
rm -rf ${work_dir};


#cd "${origin_dir}"
#(/home/compass/sacompass/previsaopld/Backup/cpas_ctl_common/test.sh)

exit $ec;