#!/bin/bash

v=2905

par=$1

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

if [ $ec == 0 -o $ec == 7 ]
then
 arq=$( cat caso.dat ) 
 if [ ! -f "sumario.$arq" ]
 then 

   echo ""
   echo "Removendo Inviabilidades"
   
   rm -f relato.bkp
   cp -pf ./relato.* ./relato.bkp   
   
   dotnet "/home/compass/sacompass/previsaopld/shared/Nova pasta/ConsoleApp1/bin/Release/netcoreapp2.0/TrataInviab.dll" 1
   
   echo "/home/compass/sacompass/previsaopld/cpas_ctl_common/scripts/decomp.sh $v nao";
   /home/compass/sacompass/previsaopld/cpas_ctl_common/scripts/decomp.sh $v nao;
   ec=$?   
   
   if [ ! -f "sumario.$arq" ]
   then    
   
     echo ""
     echo "Removendo Inviabilidades - segunda iteracao"
   
     rm -f relato.bkp
     cp -pf ./relato.* ./relato.bkp 
	 
	 dotnet "/home/compass/sacompass/previsaopld/shared/Nova pasta/ConsoleApp1/bin/Release/netcoreapp2.0/TrataInviab.dll" 3
	 
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


exit $ec;