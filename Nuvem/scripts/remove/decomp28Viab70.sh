#!/bin/bash

v=28

par=$1

if [[ "$par" == "preliminar" ]]
then
   echo "/home/producao/PrevisaoPLD/cpas_ctl_common/scripts/decomp70.sh $v 25 nao";
   /home/producao/PrevisaoPLD/cpas_ctl_common/scripts/decomp70.sh $v 25 nao;
   ec=$?    
else
   echo "/home/producao/PrevisaoPLD/cpas_ctl_common/scripts/decomp70.sh $v 25";
   /home/producao/PrevisaoPLD/cpas_ctl_common/scripts/decomp70.sh $v 25;
   ec=$? 
fi

if [[ $ec == 0 ]]
then

 arq=$( cat caso.dat ) 
 if [ ! -f "sumario.$arq" ]
 then 

   echo ""
   echo "Removendo Inviabilidades"
   
   rm -f relato.bkp
   cp -pf ./relato.* ./relato.bkp   
   
   dotnet "/home/producao/PrevisaoPLD/shared/Nova pasta/ConsoleApp1/bin/Release/netcoreapp2.0/TrataInviab.dll"
   
   echo "/home/producao/PrevisaoPLD/cpas_ctl_common/scripts/decomp70.sh $v 25 nao";
   /home/producao/PrevisaoPLD/cpas_ctl_common/scripts/decomp70.sh $v 25 nao;
   ec=$?   
  fi
fi

exit $ec;