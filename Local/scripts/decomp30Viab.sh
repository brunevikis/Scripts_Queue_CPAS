#!/bin/bash

v=30

par=$1

if [[ "$par" == "preliminar" ]]
then
   echo "/home/producao/PrevisaoPLD/cpas_ctl_common/scripts/decomp.sh $v nao";
   /home/producao/PrevisaoPLD/cpas_ctl_common/scripts/decomp.sh $v nao;
   ec=$?    
else
   echo "/home/producao/PrevisaoPLD/cpas_ctl_common/scripts/gevazp2020.sh";
   /home/producao/PrevisaoPLD/cpas_ctl_common/scripts/gevazp2020.sh
   echo "/home/producao/PrevisaoPLD/cpas_ctl_common/scripts/decomp.sh $v";
   /home/producao/PrevisaoPLD/cpas_ctl_common/scripts/decomp.sh $v nao;
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
   
   dotnet "/home/producao/PrevisaoPLD/shared/price_tools/inviab/bin/Release/netcoreapp2.0/TrataInviab.dll" 1
   
   echo "/home/producao/PrevisaoPLD/cpas_ctl_common/scripts/decomp.sh $v nao";
   /home/producao/PrevisaoPLD/cpas_ctl_common/scripts/decomp.sh $v nao;
   ec=$?   
   
   if [ ! -f "sumario.$arq" ]
   then    
   
     echo ""
     echo "Removendo Inviabilidades - segunda iteracao"
   
     rm -f relato.bkp
     cp -pf ./relato.* ./relato.bkp 
	 
	 dotnet "/home/producao/PrevisaoPLD/shared/price_tools/inviab/bin/Release/netcoreapp2.0/TrataInviab.dll" 3            	 
			
	 
	 echo "/home/producao/PrevisaoPLD/cpas_ctl_common/scripts/decomp.sh $v nao";
     /home/producao/PrevisaoPLD/cpas_ctl_common/scripts/decomp.sh $v nao;
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