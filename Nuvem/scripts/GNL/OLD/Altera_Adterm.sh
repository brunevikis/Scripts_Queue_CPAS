#!/bin/bash

Alterar_Adterm()
{
	i=0
	j=0
	mes=1
	linha_Usina=False
	bloco_Antigo=""
	bloco_Novo=""
	
	Dir_Atual=$(pwd)
	n=6
	pos=${#Dir_Atual}
	n_5=$((pos-6))
	Pasta_Data=${Dir_Atual:$n_5:$n}	
	insertpoint=2
	grep 'IUTE\|XXXX'  "adterm.dat" > "adterm.dat".temp
	IFS=$'\n'

	while read d1
	do
		i=$((i+1))
		j=$((j+1))

		linha_AD=$(echo "$d1")
		if [[ i -gt 2 ]];
		then
			if [[ j -eq 3 ]];
			then
				j=0	
				usina=$(echo "$d1" | cut -c1-6 | sed "s/ //g" | sed "s/[[:alpha:]]//g") 
				bloco_Antigo=$bloco_Antigo$linha_AD$'\n'
				bloco_Novo="$bloco_Novo$linha_AD"$'\n'
			else
				bloco_Antigo="$bloco_Antigo""$linha_AD"$'\n'
				if [[ mes -eq 1 ]];
				then
					mes=$((mes+1))
					Pasta_Ben=$((Pasta_Data-2))
				else
					mes=1
					Pasta_Ben=$((Pasta_Data-1))
				fi
				n=6
				pos=${#d1}
				n_5=$((pos-$n))
				pat1=${d1:$n_5:$n}

				cd ..
        
        		dcPaths=$( ls | grep -E '^20[0-9]{4}' -v | grep 'DCGNL' )

				cd $Pasta_Data
				
				if [ -d "../$dcPaths/$Pasta_Ben" ];
				then
					echo "Entrou Aquiiiiiiiiii"
					IFS=";"
					while read f1 f2 f3 f4 Usina_Ben Nome Pat Ben Custo
					do
						if [[ "    1 " == "$f1" ]];
						then
							if [[ "$Ben" > "$Custo" ]];
							then
								
								Usina_Ben=$(echo "$Usina_Ben" | sed "s/ //g")
								
								if [[ "$Usina_Ben" == "$usina" && ${Pat:2:2} -eq 1 ]];
								then
								
									pat1_Ben=${Ben:5:7}
								
								elif [[ "$Usina_Ben" == "$usina" && ${Pat:2:2} -eq 2 ]];
								then
									
									pat2_Ben=${Ben:5:7}
								
								elif [[ "$Usina_Ben" == "$usina" && ${Pat:2:2} -eq 3 ]];
								then

									pat3_Ben=${Ben:5:7}
								
								fi	
							else
								Usina_ben=$(echo "${Usina_Ben:1:3}" | sed "s/ //g")
								if [[ "${Usina_Ben:1:3}" == "$usina" && ${Pat:2:2} -eq 1 ]];
								then	
									pat1_Ben="000.00"	
								
								elif [[ "${Usina_Ben:1:3}" == "$usina" && ${Pat:2:2} -eq 2 ]];
								then

									pat2_Ben="000.00"

								elif [[ "${Usina_Ben:1:3}" == "$usina" && ${Pat:2:2} -eq 3 ]];
								then
									pat3_Ben="000.00"

								fi
							fi
						fi
					
					done < ../$dcPaths/$Pasta_Ben/bengnl.csv
						
					if [[ "$pat1_Ben" != "0" ]];
					then

						linha_nova=$(echo "$linha_AD" | sed "s/${pat1}/${pat1_Ben:0:6}/g" )

						linha_nova=$(echo "$linha_nova" | sed "s/${pat1}/${pat2_Ben:0:6}/g" )
							
						linha_nova=$(echo "$linha_nova" | sed "s/${pat1}/${pat3_Ben:0:6}/g" )
						
						echo $linha_nova
						bloco_Novo="$bloco_Novo""$linha_nova"$'\n'	
						#sed -i "/$linha_AD/{s/$linha_AD/$linha_nova/;:a;N;ba}" adterm.dat
						
						#sed -i "s/$linha_AD/$linha_nova/g" adterm.dat
							
					else
						
						linha_nova=$(echo "$linha_AD" | sed "s/${pat1}/${pat1_Ben:0:6}/g" )

						linha_nova=$(echo "$linha_nova" | sed "s/${pat1}/${pat2_Ben:0:6}/g" )
							
						linha_nova=$(echo "$linha_nova" | sed "s/${pat1}/${pat3_Ben:0:6}/g" )

						#linha_nova=$linha_AD
						bloco_Novo="$bloco_Novo""$linha_nova"$'\n'	
						#linha_nova=$(echo "$linha_GL" | sed -e "s/${pat1}/${pat1_Ben}/" )
						teste32=0
					fi
				else

					echo $linha_nova
					linha_nova=$linha_AD
					bloco_Novo="$bloco_Novo""$linha_nova"$'\n'		
				fi	
			fi	
		fi
	done < adterm.dat

	#echo "$bloco_Antigo" >> Teste.log
	#echo "$bloco_Novo" >> Teste.log
	echo "$bloco_Novo" > adterm.dat.temp.modif

	sed -i "$insertpoint r ""adterm.dat"".temp.modif" "adterm.dat".temp

	mv "adterm.dat".temp "adterm.dat"
}

Alterar_Adterm