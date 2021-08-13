#!/bin/bash

Alterar_Dadgnl(){
	j=0
	
	while read d1
	do
		linha_GL=$(echo "$d1" | grep -w "GL")
		if [ "$linha_GL" != "" ];
		then
			usina=$(echo "$linha_GL" | cut -c5-7)
			SS=$(echo "$linha_GL" | cut -c11-11)
			NLAG=$(echo "$linha_GL" | cut -c16-16)
			data_DG=$(echo "$linha_GL" | cut -c68-73)
			pat1=$(echo "$linha_GL" | cut -c25-29)
			pat2=$(echo "$linha_GL" | cut -c40-44)
			pat3=$(echo "$linha_GL" | cut -c55-59)
			Lim=$(cat dadgnl.rv? | grep "TG  $usina" | cut -c35-40)
			Lim1=${Lim:0:5}			
			

			#Pat1_Oficial=$(cat dadgnl.rv?_original.bak | grep "$usina" | grep "$SS    $NLAG" | grep "$data_DG" | cut -c24-26)
			#Pat2_Oficial=$(cat dadgnl.rv?_original.bak | grep "$usina" | grep "$SS    $NLAG" | grep "$data_DG" | cut -c40-42)
			#Pat3_Oficial=$(cat dadgnl.rv?_original.bak | grep "$usina" | grep "$SS    $NLAG" | grep "$data_DG" | cut -c55-57)

			Pat1_Oficial=$(cat dadgnl.rv?_original.bak | grep "$usina" | grep "$SS" | grep "$data_DG" | cut -c24-29 | sed "s/ //g")
			Pat2_Oficial=$(cat dadgnl.rv?_original.bak | grep "$usina" | grep "$SS" | grep "$data_DG" | cut -c40-44 | sed "s/ //g")
			Pat3_Oficial=$(cat dadgnl.rv?_original.bak | grep "$usina" | grep "$SS" | grep "$data_DG" | cut -c55-60 | sed "s/ //g")
			echo $usina
			

			Pat1_Oficial=${Pat1_Oficial:0:5}
			Pat2_Oficial=${Pat2_Oficial:0:5}
			Pat3_Oficial=${Pat3_Oficial:0:5}

		

			if [ "$Pat1_Oficial" != "" ];
			then
				if [[ "$Pat1_Oficial" < "$Lim1" ]];
				then

					if [ "${Pat1_Oficial:0:1}" == "0" ];
					then
						Pat1_Oficial="000.0"
						linha_nova=$(echo "$linha_GL" | sed -e "s/${pat1}/${Pat1_Oficial}/" )
					else
						
						linha_nova=$(echo "$linha_GL" | sed -e "s/${pat1}/${Pat1_Oficial}/" )
					fi
				else
					if [ "$Lim1" == "0.0" ];
					then
						linha_nova=$linha_GL
					else
						linha_nova=$(echo "$linha_GL" | sed -e "s/${pat1}/${Lim1}/" )
					fi
				fi

				if [[ "$Pat2_Oficial" < "$Lim1" ]];
				then
					if [ "${Pat2_Oficial:0:1}" == "0" ];
					then
						Pat2_Oficial="000.0"
						linha_nova=$(echo "$linha_nova" | sed -e "s/${pat2}/${Pat2_Oficial}/" )
					else 
						linha_nova=$(echo "$linha_nova" | sed -e "s/${pat2}/${Pat2_Oficial}/" )
					fi
				else
					if [ "$Lim1" == "0.0" ];
					then
						linha_nova=$linha_GL
					else
						linha_nova=$(echo "$linha_nova" | sed -e "s/${pat2}/${Lim1}/" )
					fi
				fi

				if [[ "$Pat3_Oficial" < "$Lim1" ]];
				then
					if [ "${Pat3_Oficial:0:1}" == "0" ];
					then
						Pat2_Oficial="000.0"
						linha_nova=$(echo "$linha_nova" | sed -e "s/${pat2}/${Pat2_Oficial}/" )
					else 
						linha_nova=$(echo "$linha_nova" | sed -e "s/${pat3}/${Pat3_Oficial}/" )
					fi
				else
				if [ "$Lim1" == "0.0" ];
					then
						linha_nova=$linha_GL
					else
						linha_nova=$(echo "$linha_nova" | sed -e "s/${pat3}/${Lim1}/" )
					fi
				fi
				
				#echo $linha_GL
				echo $linha_nova >> ../../logGNL.log;

				sed -i "s/$linha_GL/$linha_nova/g" dadgnl.rv?
			else
				Dir_Atual=$(pwd)

				#Pasta_Ano=$(pwd | cut -d"/" -f8 | cut -c1-4)
				
				n=4
				pos=${#Dir_Atual}
				n_5=$((pos-6))
				Pasta_Ano=${Dir_Atual:$n_5:$n}
				
				Mes_L=${data_DG:0:2}			
				
				#Coloca Zero a Esquerda no Mes
				if [[ "$Mes_L" == "01" || "$Mes_L" == "02" ]];
				then
					
					mes_Ben=$((Mes_L+10))
				else
					
					mes_Ben=$((10#$Mes_L-2))
					if [[ "$mes_Ben" == "10" || "$mes_Ben" == "11" || "$mes_Ben" == "12" ]];
					then
						echo ""
					else
						mes_Ben="0"$mes_Ben
						mes_Ben=${mes_Ben:0:2}
					fi
					
				fi
				
				
				Pasta_Ben="$Pasta_Ano""$mes_Ben"
				
			 	pat1_Ben=0
				pat2_Ben=0
				pat3_Ben=0
				IFS=";"
				while read f1 f2 f3 f4 Usina_Ben Nome Pat Ben Custo
				do
					if [[ "    1 " == "$f1" ]];
					then
						
						if [[ "$Ben" > "$Custo" ]];
						then
							
							if [[ "${Usina_Ben:1:3}" == "$usina" && ${Pat:2:2} -eq 1 ]];
							then

								pat1_Ben=${Ben:5:7}
								echo $pat1_Ben

							elif [[ "${Usina_Ben:1:3}" == "$usina" && ${Pat:2:2} -eq 2 ]];
							then

								pat2_Ben=${Ben:5:7}
								echo $pat2_Ben
								
							elif [[ "${Usina_Ben:1:3}" == "$usina" && ${Pat:2:2} -eq 3 ]];
							then

								pat3_Ben=${Ben:5:7}
								echo $pat3_Ben
								
							fi	
						else
							if [[ "${Usina_Ben:1:3}" == "$usina" && ${Pat:2:2} -eq 1 ]];
							then

								pat1_Ben="0"	
								
							elif [[ "${Usina_Ben:1:3}" == "$usina" && ${Pat:2:2} -eq 2 ]];
							then

								pat2_Ben="0"

							elif [[ "${Usina_Ben:1:3}" == "$usina" && ${Pat:2:2} -eq 3 ]];
							then

								pat3_Ben="0"

							fi
						fi
					fi
				done < ../$Pasta_Ben/bengnl.csv

				if [-d "../$Pasta_Ben/bengnl.csv"];
				then
					if [[ "$pat1_Ben" != "0" ]];
					then

						pat1_BenS=$(echo "scale=0 ; ${pat1_Ben:0:3}" | bc)	
						LimS=$(echo "scale=0 ; ${Lim:0:4}" | bc)
				
						if [ $pat1_BenS -lt $LimS ];
						then 
							#echo ${pat1} ${pat1_Ben:0:5} 
							linha_nova=$(echo "$linha_GL" | sed -e "s/${pat1}/${pat1_Ben:0:5}/g" )
							#echo "$linha_nova"
					
						else
							linha_nova=$(echo "$linha_GL" | sed -e "s/${pat1}/${Lim1}/" )
						fi

						pat2_BenS=$(echo "scale=0 ; ${pat2_Ben:0:3}" | bc)
						if [ $pat2_BenS -lt $LimS ];
						then
							#echo ${pat1} ${pat1_Ben:0:5}  
							linha_nova=$(echo "$linha_nova" | sed -e "s/${pat2}/${pat2_Ben:0:5}/g" )
					
						else
							linha_nova=$(echo "$linha_nova" | sed -e "s/${pat2}/${Lim1}/" )
						fi

						pat3_BenS=$(echo "scale=0 ; ${pat3_Ben:0:3}" | bc)
						if [ $pat3_BenS -lt $LimS ];
						then 
					
							linha_nova=$(echo "$linha_nova" | sed -e "s/${pat3}/${pat3_Ben:0:5}/g" )
						else
							linha_nova=$(echo "$linha_nova" | sed -e "s/${pat3}/${Lim1}/" )
						fi
						echo $linha_nova >> ../../logGNL.log;
						sed -i "s/$linha_GL/$linha_nova/" dadgnl.rv?
					else
						#linha_nova=$(echo "$linha_GL" | sed -e "s/${pat1}/${pat1_Ben}/" )
						echo $linha_GL >> ../../logGNL.log;
						echo "Zero"
					fi
				
					#echo "$linha_GL"
					#echo "$linha_nova"	

				fi
			fi
		fi
	done < dadgnl.rv?	
}

Alterar_Dadgnl