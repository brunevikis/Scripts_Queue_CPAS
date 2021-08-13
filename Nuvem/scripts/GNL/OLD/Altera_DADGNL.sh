#!/bin/bash

#Alterar_Dadgnl(){
	j=0
	dadgnl=$(find .  -iname dadgnl.rv?)	
    total=""
	bloco_Antigo=""
	IFS=$'\n'  
	grep 'IUTE\|XXXX'  "adterm.dat" > "adterm.dat".temp
	insertpoint=$( grep -e "^NL" "$dadgnl".temp -n | tail -n1 | cut -f1 -d":" )
	while read  d1
	do
		linha_GL=$(echo "$d1" | grep -w "GL")
		if [ "$linha_GL" != "" ];
		then
			
			bloco_Antigo="$bloco_Antigo""$linha_GL"$'\n'
			  
			usina=$(echo "$linha_GL" | cut -c5-7)
			SS=$(echo "$linha_GL" | cut -c11-11)
			NLAG=$(echo "$linha_GL" | cut -c16-16)
			data_DG=$(echo "$linha_GL" | cut -c68-73)
			pat1=$(echo "$linha_GL" | cut -c25-29)
			pat2=$(echo "$linha_GL" | cut -c40-44)
			pat3=$(echo "$linha_GL" | cut -c55-59)
			Lim=$(cat $dadgnl | grep "TG  $usina" | cut -c35-40)
			Lim1=${Lim:0:5}			
			
			#echo $linha_GL
			n=6
			pos=${#linha_GL}
			
			n_6=$((pos-6))
			data_DG=${linha_GL:$n_6:$n}
				
			echo "Teste data ${data_DG:0:6}"

			Pat1_Oficial=$(cat "$dadgnl"_original.bak | grep "$usina" | grep "$SS" | grep "${data_DG:0:6}" | cut -c24-29 | sed "s/ //g")
			Pat2_Oficial=$(cat "$dadgnl"_original.bak | grep "$usina" | grep "$SS" | grep "${data_DG:0:6}" | cut -c40-44 | sed "s/ //g")
			Pat3_Oficial=$(cat "$dadgnl"_original.bak | grep "$usina" | grep "$SS" | grep "${data_DG:0:6}" | cut -c55-60 | sed "s/ //g")
			

			Pat1_Oficial=${Pat1_Oficial:0:5}
			Pat2_Oficial=${Pat2_Oficial:0:5}
			Pat3_Oficial=${Pat3_Oficial:0:5}

			if [ "$Pat1_Oficial" != "" ];
			then
				if [[ "$Pat1_Oficial" < "$Lim1" ]];
				then

					if [ "${Pat1_Oficial:0:1}" == "0" ];
					then
						Pat1_Oficial="0"
						echo "SED 1"
                        linha_nova=$(echo "$linha_GL" | sed "s/\(^GL.\{22\}\)\(.\)\{5\}/\1    ${Pat1_Oficial}/" )
						
						#linha_nova=$(echo "$linha_GL" | sed -e "s/${pat1}/${Pat1_Oficial}/" )
					else
						echo "SED 2"
						linha_nova=$(echo "$linha_GL" | sed "s/\(^GL.\{18\}\)\(.\)\{9\}/\1    ${Pat1_Oficial}/" )
						
						#linha_nova=$(echo "$linha_GL" | sed -e "s/${pat1}/${Pat1_Oficial}/" )
					fi
				else
					if [ "$Lim1" == "0.0" ];
					then

						linha_nova=$linha_GL
					else
						echo "SED 3"
                        linha_nova=$(echo "$linha_GL" | sed "s/\(^GL.\{18\}\)\(.\)\{9\}/\1    ${Lim1}/" )
						#linha_nova=$(echo "$linha_GL" | sed -e "s/${pat1}/${Lim1}/" )
					fi
				fi

				if [[ "$Pat2_Oficial" < "$Lim1" ]];
				then
					if [ "${Pat2_Oficial:0:1}" == "0" ];
					then
						Pat2_Oficial="0"
						echo "SED 4"
                        linha_nova=$(echo "$linha_nova" | sed "s/\(^GL.\{37\}\)\(.\)\{5\}/\1    ${Pat2_Oficial}/" )
						
						#linha_nova=$(echo "$linha_nova" | sed -e "s/${pat2}/${Pat2_Oficial}/" )
					else 
						echo "SED 5"
                        linha_nova=$(echo "$linha_nova" | sed "s/\(^GL.\{33\}\)\(.\)\{9\}/\1    ${Pat2_Oficial}/" )
						
						#linha_nova=$(echo "$linha_nova" | sed -e "s/${pat2}/${Pat2_Oficial}/" )
					fi
				else
					if [ "$Lim1" == "0.0" ];
					then
						linha_nova=$linha_GL
					else
						echo "SED 6"
                        linha_nova=$(echo "$linha_nova" | sed "s/\(^GL.\{33\}\)\(.\)\{9\}/\1    ${Lim1}/" )
						
						#linha_nova=$(echo "$linha_nova" | sed -e "s/${pat2}/${Lim1}/" )
					fi
				fi

				if [[ "$Pat3_Oficial" < "$Lim1" ]];
				then
					if [ "${Pat3_Oficial:0:1}" == "0" ];
					then
						Pat3_Oficial="0"
						echo "SED 7"
                        linha_nova=$(echo "$linha_nova" | sed "s/\(^GL.\{52\}\)\(.\)\{5\}/\1    ${Pat3_Oficial}/" )
						
						#linha_nova=$(echo "$linha_nova" | sed -e "s/${pat2}/${Pat2_Oficial}/" )
					else 
						echo "SED 8"
                        linha_nova=$(echo "$linha_nova" | sed "s/\(^GL.\{48\}\)\(.\)\{9\}/\1    ${Pat3_Oficial}/" )
		
						#linha_nova=$(echo "$linha_nova" | sed -e "s/${pat3}/${Pat3_Oficial}/" )
					fi
				else
				if [ "$Lim1" == "0.0" ];
					then
						linha_nova=$linha_GL
					else
						echo "SED 9"
                        linha_nova=$(echo "$linha_nova" | sed "s/\(^GL.\{48\}\)\(.\)\{9\}/\1    ${Lim1}/" )
						
						#linha_nova=$(echo "$linha_nova" | sed -e "s/${pat3}/${Lim1}/" )
					fi
				fi
				
				#echo $linha_GL
				#echo $linha_nova >> ../../logGNL.log;

				#echo "$linha_GL"
				#echo "$linha_nova"
				echo "SED Master1"
				total="$total""$linha_nova"$'\n'
				#sed -i.bak "s/$linha_GL/$linha_nova/g" $dadgnl
				#rm $dadgnl.bak
				
			else
				

				#Pasta_Ano=$(pwd | cut -d"/" -f8 | cut -c1-4)
				Dir_Atual=$(pwd)
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
							

							elif [[ "${Usina_Ben:1:3}" == "$usina" && ${Pat:2:2} -eq 2 ]];
							then

								pat2_Ben=${Ben:5:7}
					
								
							elif [[ "${Usina_Ben:1:3}" == "$usina" && ${Pat:2:2} -eq 3 ]];
							then

								pat3_Ben=${Ben:5:7}
			
								
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
                echo "../$Pasta_Ben/bengnl.csv"
				if [ -f "../$Pasta_Ben/bengnl.csv" ];
				then
                    echo "Achou a Pasta Bengnl"
					if [[ "$pat1_Ben" != "0" ]];
					then
                        
						pat1_BenS=$(echo "scale=0 ; ${pat1_Ben:0:3}" | bc)	
						LimS=$(echo "scale=0 ; ${Lim:0:4}" | bc)
                        echo "Não é zero $pat1_Ben $LimS"
						if [ $pat1_BenS -lt $LimS ];
						then 
							echo "SED 10"
                            linha_nova=$(echo "$linha_GL" | sed "s/\(^GL.\{18\}\)\(.\)\{9\}/\1    ${pat1_Ben:0:5}/g" )
							#linha_nova=$(echo "$linha_GL" | sed -e "s/${pat1}/${pat1_Ben:0:5}/g" )
							
					
						else
							echo "SED 11"
                            linha_nova=$(echo "$linha_GL" | sed "s/\(^GL.\{18\}\)\(.\)\{9\}/\1    ${Lim1}/g" )
							#linha_nova=$(echo "$linha_GL" | sed -e "s/${pat1}/${Lim1}/" )
						fi

						pat2_BenS=$(echo "scale=0 ; ${pat2_Ben:0:3}" | bc)
						if [ $pat2_BenS -lt $LimS ];
						then
							#echo ${pat1} ${pat1_Ben:0:5} 
							echo "SED 12"
                            linha_nova=$(echo "$linha_nova" | sed "s/\(^GL.\{33\}\)\(.\)\{9\}/\1    ${pat2_Ben:0:5}/g" ) 
							#linha_nova=$(echo "$linha_nova" | sed -e "s/${pat2}/${pat2_Ben:0:5}/g" )
					
						else
							echo "SED 13"
                            linha_nova=$(echo "$linha_nova" | sed "s/\(^GL.\{33\}\)\(.\)\{9\}/\1    ${Lim1}/g" ) 
							#linha_nova=$(echo "$linha_nova" | sed -e "s/${pat2}/${Lim1}/" )
						fi

						pat3_BenS=$(echo "scale=0 ; ${pat3_Ben:0:3}" | bc)
						if [ $pat3_BenS -lt $LimS ];
						then 
							echo "SED 14"
                            linha_nova=$(echo "$linha_nova" | sed "s/\(^GL.\{48\}\)\(.\)\{9\}/\1    ${pat3_Ben:0:5}/g" ) 
							#linha_nova=$(echo "$linha_nova" | sed -e "s/${pat3}/${pat3_Ben:0:5}/g" )
						else
							echo "SED 15"
                            linha_nova=$(echo "$linha_nova" | sed "s/\(^GL.\{48\}\)\(.\)\{9\}/\1    ${Lim1}/g" ) 
							#linha_nova=$(echo "$linha_nova" | sed -e "s/${pat3}/${Lim1}/" )
						fi
						echo $linha_nova >> ../../logGNL.log;

						#echo "$linha_GL"
						#echo "$linha_nova"
						echo "Master 2"	
						total="$total""$linha_nova"$'\n'
						
						#sudo sed -i.bak "s/$linha_GL/$linha_nova/" $dadgnl
					else
						#linha_nova=$(echo "$linha_GL" | sed -e "s/${pat1}/${pat1_Ben}/" )
						linha_nova=$linha_GL
						total="$total""$linha_nova"$'\n'
						echo $linha_GL >> ../../logGNL.log;
						#echo "Zero"
					fi
				
					#echo "$linha_GL"
					#echo "$linha_nova"	

				fi
			fi
		fi
	done < $(find .  -iname dadgnl.rv?)	


	#echo $bloco_Antigo
	


	echo $bloco_Antigo >> Teste.log
	echo $total >> Teste.log
	echo $total > "$dadgnl".temp.modif

	sed -i "$insertpoint r ""$dadgnl"".temp.modif" "$dadgnl".temp

	mv "$dadgnl".temp "$dadgnl"
#}

#Alterar_Dadgnl