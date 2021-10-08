#!/bin/bash



agendaDC(){
    echo "AGENDAR DC - $1"
    dt=$(date +%Y%m%d%H%M%S)
    ord=$(( 20 + 10#$mesN ))
    usr="encad"
    fn="/home/compass/queuectl/queue/encadeado_DC${ano}${mes}_${dt}"
    cmd="/home/compass/sacompass/previsaopld/cpas_ctl_common/scripts/decomp301Viab.sh"
    
    printf -v newComm "%s\n" "ord=${ord}" "usr=${usr}" "dir=$1" "cmd=${cmd}" "ign=False" "cluster="
    
    echo ""
    echo "$newComm" > ${fn}
}


AgendaProximaIteracao(){
    echo "AGENDAR NW - $1"
    dt=$(date +%Y%m%d%H%M%S)
    ord=$(( 20 + 10#$mesN ))
    usr="encad"
    fn="/home/compass/queuectl/queue/encadeado_NW${anoN}${mesN}_${dt}"
    cmd="/home/compass/sacompass/previsaopld/cpas_ctl_common/scripts/GNL/encad_earmNW_27.sh $1"

    printf -v newComm "%s\n" "ord=${ord}" "usr=${usr}" "dir=$( pwd )" "cmd=${cmd}" "ign=False" "cluster="

    echo ""
    echo "$newComm" > ${fn}
}

v=301

par=$1


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

Dir_Atual=$(pwd)
				
n=6
pos=${#Dir_Atual}
n_6=$((pos-6))
anomes=${Dir_Atual:$n_6:$n}


echo $anomes

ano=${anomes:0:4}
mes=${anomes:4:2}
echo $ano
echo $mes

# ALTERAR DADGNL

echo "/usr/bin/dotnet /home/compass/sacompass/previsaopld/shared/price_tools/inviab/bin/Debug/netcoreapp2.0/TrataInviab.dll dadgnl";

/usr/bin/dotnet /home/compass/sacompass/previsaopld/shared/price_tools/inviab/bin/Debug/netcoreapp2.0/TrataInviab.dll "dadgnl"

cd ..
cd ..

dcPaths=$( ls | grep -E '^20[0-9]{4}' -v )

for dc in $dcPaths ; do

            if [ -d "$dc/$ano$mes" ]; then

                gnl=$(echo $dc | grep DCGNL)
				
                if [ "$gnl" == "" ];
				then
					
                    RV0=$(echo $dc | grep RV0)

                    if [ ! "$RV0" == "" ];
                    then

                        cd "$( pwd )/$dc/$ano$mes"


                        echo "Alterando DADGNL RV0"
                        /usr/bin/dotnet /home/compass/sacompass/previsaopld/shared/price_tools/inviab/bin/Debug/netcoreapp2.0/TrataInviab.dll "RV0"

                        cd ..
                        cd ..

                        agendaDC "$( pwd )/$dc/$ano$mes"
                        sleep 2
                        echo ""
                    else

                        echo "Copiando DADGNL para sensibilidades"
                        echo "cp -b $origin_dir/DADGNL.$arqName $( pwd )/$dc/$ano$mes/DADGNL.$arqName"
                        cp -b $origin_dir/DADGNL.$arqName $( pwd )/$dc/$ano$mes/dadgnl.$arqName

                        agendaDC "$( pwd )/$dc/$ano$mes"
                        sleep 2
                        echo ""

                    fi
                        


				fi

                
            fi
    done
    
cd $origin_dir




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

# Parte Nova

cd "${origin_dir}"
cd ..
cd ..

mesN=$(( 10#$mes + 1 ))
anoN=$ano
       
if [[ "$mesN" == "13" ]]; then

    mesN="01"
    anoN=$(( $anoN + 1 ))
fi
        
printf -v mesN "%02i" $mesN


if [ -d $anoN$mesN ]; then    
            
    #agenda proximomes
    AgendaProximaIteracao "$anoN$mesN"
fi



exit $ec;




