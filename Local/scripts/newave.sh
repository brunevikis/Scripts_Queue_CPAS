#!/bin/bash
#script para a execucao do newave (${ver})

ver=$1
tipoSim=$2
flags="1    1    1    0    0"

hostfile="/home/producao/PrevisaoPLD/cpas_ctl_common/hosts/$( hostname ).hosts.mpi"
cores=0

for nx in $( cat $hostfile | cut -d":" -f2 ); do cores=$(( $cores + $nx )); done

echo "versão         : $ver"
echo "# cores        : $cores"
echo "$hostfile      :"
echo "$( cat $hostfile )"
echo "tipo simulação : $tipoSim"
echo "flags          : $flags"

#nm=$(cat /etc/hosts.mpi | grep -v '#' | wc -l)
#cores=$(( 15 * $nm ))

export HYDRA_HOST_FILE=$hostfile
export LD_LIBRARY_PATH=/usr/local/bin/lib:$LD_LIBRARY_PATH

INICIO=$(date)

if [ ! -f "dger.dat" ]; then
        if [ ! -f "DGER.DAT" ]; then
            echo "!! Erro no deck, arquivo dger.dat não encontrado !!";
            exit 1;
        fi;
fi;




echo -e "\n"
echo "-----------[ Escrevendo caso.dat ] --------------"
rm -f caso.dat
rm -f CASO.DAT
echo "arquivos.dat" > caso.dat
echo "/home/producao/PrevisaoPLD/shared/install/newave/newave_${ver}/Executaveis/" >> caso.dat


echo -e "\n"
echo "-----------[ Convertendo nome dos arquivos ] --------------"
echo /home/producao/PrevisaoPLD/shared/install/newave/newave_${ver}/Executaveis/ConverteNomesArquivos
/home/producao/PrevisaoPLD/shared/install/newave/newave_${ver}/Executaveis/ConverteNomesArquivos;

echo "pld.dat --> pmo.dat"
sed '13s/\(^.\{30\}\).*/\1pmo.dat/' arquivos.dat -i




if [ -z $tipoSim ]; then
    lineTipoSim=$(sed '27!d' dger.dat);
	tipoSim=${lineTipoSim:24:1};
fi

lineTipoExec=$(sed '2!d' dger.dat);
tipoExec=${lineTipoExec:24:1};





if [ $tipoExec -eq 1 ]; then

	echo -e "\n"
	echo "-----------[ Limpando sujeira ] --------------"
			rm -f forward.dat;
			rm -f forward.zip;
			rm -f cortes.dat;
			rm -f cortes.zip;
			rm -f cortesh.dat;
			rm -f cortese.dat;
			rm -f energiab.dat;
			rm -f energiab.zip;
			rm -f pmo.dat;
			rm -f *.out;


		#rodar consistencia antes de iniciar processamento;
		cp dger.dat dger.dat.ori
		sed '27s/\(^.\{21\}\).\{4\}\(.*\)/\1   3\2/' dger.dat -i

		if [ -f "pmo.dat" ]; then
			rm pmo.dat;
		fi;

		echo -e "\n"
		echo "-----------[ Executando consistencia ] --------------"
		echo /home/producao/PrevisaoPLD/shared/install/newave/newave_${ver}/Executaveis/newave${ver}_L
		/home/producao/PrevisaoPLD/shared/install/newave/newave_${ver}/Executaveis/newave${ver}_L;

		rm dger.dat;
		mv dger.dat.ori dger.dat;

		echo -e "\n"
		if [ ! -f "pmo.dat" ]; then     
			echo "!! Erro no deck, verificar output !!";
			exit 1;
		fi;
		if [ -z "$( cat "pmo.dat" | grep "NENHUM ERRO FOI DETECTADO NA LEITURA DOS DADOS" )" ]; then 
			echo "!! Erro de dados, ver pmo.dat !!"; 
			exit 1;
		fi;

		if [ $tipoSim -eq 1 -o $tipoSim -eq 2 ]; then

			sed '27s/\(^.\{21\}\).\{4\}\(.*\)/\1   '"$tipoSim"'\2/' dger.dat -i
            sed '59s/\(^.\{21\}\).\{24\}\(.*\)/\1   '"$flags"'\2/' dger.dat -i

			#guardar diretorio do caso
			origin_dir=$(pwd)
			#definir diretorio para processamento  /opt/aplicacoes/newave/arquivo/recebido/$(date +%Y%m%d%H%M%s%N)
			work_dir=/opt/aplicacoes/newave/arquivo/recebido/$(date +%Y%m%d%H%M%s%N)/
			#copiar deck
		     
            for xx in `tail -n+2 "${hostfile}" | grep -v '#' | cut -d":" -f1`; do ssh $xx "mkdir -p $work_dir"; done      
		 
			echo -e "\n"
			echo "-----------[ Copiando deck para pasta de processamento ] --------------"
			echo cp -rp "${origin_dir}" "${work_dir}"
			cp -rp "${origin_dir}" "${work_dir}"
		 
			#executar
			cd "${work_dir}"
		 
			echo -e "\n"
			echo "-----------[ Executando o Newave ] --------------"
            echo "/opt/aplicacoes/mpich-3.1.4/install/bin/mpiexec -f ${hostfile} -n ${cores} /home/producao/PrevisaoPLD/shared/install/newave/newave_${ver}/Executaveis/newave${ver}_L"
            /opt/aplicacoes/mpich-3.1.4/install/bin/mpiexec -f "${hostfile}" -n ${cores} /home/producao/PrevisaoPLD/shared/install/newave/newave_${ver}/Executaveis/newave${ver}_L;

		    echo "-----------[ Comprimindo alguns arquivos ] --------------"    
			zip -q arq_bases arq_bases.bin && rm -f arq_bases.bin;
			zip -q forward forward.dat && rm -f forward.dat;
			zip -q cortese cortese.dat && rm -f cortese.dat;
			zip -q energiab energiab.dat && rm -f energiab.dat;
		 
			echo -e "\n"
			echo "-----------[ Devolvendo resultados e excluindo pasta de trabalho ] --------------"
			cp -f * "${origin_dir}";
            wait;
            rm -rf ${work_dir};
            for xx in `tail -n+2 "${hostfile}" | grep -v '#' | cut -d":" -f1`; do ssh $xx "rm -rf $work_dir"; done
		 
			cd "${origin_dir}"

		fi;




	#construindo eafpast.dat

	if [ -f "pmo.dat" ]; then
		cut -c-4 ree.dat | tail -n+2 | head -n-1 > eafpast_a.dat
		cat pmo.dat | sed -n "/ENERGIAS AFLUENTES PASSADAS PARA A TENDENCIA HIDROLOGICA/,/ENERGIAS AFLUENTES PASSADAS EM REFERENCIA/p" | tail -n+3 | head -n $( cat eafpast_a.dat | wc -l ) | cut -c2- > eafpast_b.dat
		paste -d" " eafpast_a.dat eafpast_b.dat > eafpast.dat
		rm eafpast_a.dat eafpast_b.dat
	fi;

else

			echo -e "\n"
			echo "-----------[ Executando o Newave SIMULACAO FINAL ] --------------"
			/home/producao/PrevisaoPLD/shared/install/newave/newave_${ver}/Executaveis/newave${ver}_L;

fi;





FIM=$(date)

echo -e "\n"
echo "Inicio da execucao       $INICIO"
echo "FIm da execucao          $FIM"
