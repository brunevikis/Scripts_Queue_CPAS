#!/bin/bash
#script para a execucao do newave (${ver})
umask 0002;
ver=$1
tipoSim=$2
flags="1    1    1    0    0"
hostfile="/home/producao/PrevisaoPLD/enercore_ctl_common/hosts/$( hostname ).hosts.mpi"
cores=0
for nx in $( cat "$hostfile" | cut -d":" -f2 ); do cores=$(( $cores + $nx )); done

echo "versão         : $ver"
echo "# cores        : $cores"
echo "$hostfile      :";cat "$hostfile"
echo "tipo simulação : $tipoSim"
echo "flags          : $flags"

export HYDRA_HOST_FILE=$hostfile
export LD_LIBRARY_PATH=/usr/local/bin/lib:$LD_LIBRARY_PATH

INICIO=$(date)
if [ ! -f "dger.dat" ]; then
        if [ ! -f "DGER.DAT" ]; then
            echo "!! Erro no deck, arquivo dger.dat não encontrado !!";
            exit 1;
        fi;
fi;
echo "-----------[ Convertendo todos os arquivos para minusculas ]-----------";
for i in $( ls -p | grep '/$' -v ); do
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
echo -e "\n-----------[ Escrevendo caso.dat ] --------------"
rm -f caso.dat
rm -f CASO.DAT
echo "arquivos.dat" > caso.dat
echo "/home/producao/PrevisaoPLD/shared/install/newave/newave_${ver}/Executaveis/" >> caso.dat
echo -e "\n-----------[ Convertendo nome dos arquivos ] --------------"
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
    rm -f ./*.out;
    #rodar consistencia antes de iniciar processamento;
    if grep -iq "SEMENTE" dger.dat; then
      if [ $(sed '99!d' dger.dat|grep -o '[0-9]'|head -1) -eq 1 ]; then
        sed -i '104s/\(^.\{24\}\)[ 0-9]\{21\}\(.*\)/\10    1   '"$(printf '%2d' $(( $(sed '6!d' dger.dat|grep -o '[0-9]*')+1 )))"'    0    0\2/' dger.dat
      else
        sed -i '104s/\(^.\{24\}\)[ 0-9]\{21\}\(.*\)/\10    2   '"$(printf '%2d' $(( $(sed '6!d' dger.dat|grep -o '[0-9]*')+1 )))"'   60    0\2/' dger.dat
      fi
    else
      if [ $(sed '97!d' dger.dat|grep -o '[0-9]'|head -1) -eq 1 ]; then
        sed -i '102s/\(^.\{24\}\)[ 0-9]\{21\}\(.*\)/\10    1   '"$(printf '%2d' $(( $(sed '6!d' dger.dat|grep -o '[0-9]*')+1 )))"'    0    0\2/' dger.dat
      else
        sed -i '102s/\(^.\{24\}\)[ 0-9]\{21\}\(.*\)/\10    2   '"$(printf '%2d' $(( $(sed '6!d' dger.dat|grep -o '[0-9]*')+1 )))"'   60    0\2/' dger.dat
      fi
    fi
    cp dger.dat dger.dat.ori
    sed '27s/\(^.\{21\}\).\{4\}\(.*\)/\1   3\2/' dger.dat -i
    if [ -f "pmo.dat" ]; then
        rm pmo.dat;
    fi;
    echo -e "\n"
    echo "-----------[ Executando consistencia ] --------------"
    echo /home/producao/PrevisaoPLD/shared/install/newave/newave_${ver}/Executaveis/newave${ver}
    /home/producao/PrevisaoPLD/shared/install/newave/newave_${ver}/Executaveis/newave${ver};
    rm dger.dat;
    mv dger.dat.ori dger.dat;
    rm -f alertainv_00* avl_* sgterm* newave_00*.log fpha_0*.svc eng*.dat vazinat.dat parp*
    echo -e "\n"
    if [ ! -f "pmo.dat" ]; then     
        echo "!! Erro no deck, verificar output !!"
        exit 1;
    fi;
    if ! grep -q "NENHUM ERRO FOI DETECTADO NA LEITURA DOS DADOS" pmo.dat; then 
        echo "!! Erro de dados, ver pmo.dat !!";
        exit 1;
    fi;
    if [ $tipoSim -eq 1 -o $tipoSim -eq 2 ]; then
        sed '27s/\(^.\{21\}\).\{4\}\(.*\)/\1   '"$tipoSim"'\2/' dger.dat -i
        sed '59s/\(^.\{21\}\).\{24\}\(.*\)/\1   '"$flags"'\2/' dger.dat -i
        #guardar diretorio do caso
        origin_dir=$(pwd)
        #definir diretorio para processamento ~/newave/$(date +%Y%m%d%H%M%s%N)
        work_dir="/dev/shm/newave/$(date +%Y%m%d%H%M%s%N)/"
        [[ ! -d /dev/shm/newave ]] && mkdir "/dev/shm/newave"
        trap "rm -r ${work_dir}" EXIT SIGTERM TERM SIGINT SIGQUIT
        #copiar deck
        echo -e "\n-----------[ Copiando deck para pasta de processamento ] --------------"
        echo cp -rp "${origin_dir}" "${work_dir}"
        cp -rp "${origin_dir}" "${work_dir}"
        #for xx in `tail -n+2 "${hostfile}" | grep -v '#' | cut -d":" -f1`; do ssh $xx "mkdir -p $work_dir"; done
        #executar
        cd "${work_dir}" || exit 2
        echo -e "\n-----------[ Executando o Newave ] --------------"
        echo "/home/producao/mpich2/bin/mpiexec -n ${cores} /home/producao/PrevisaoPLD/shared/install/newave/newave_${ver}/Executaveis/newave${ver}"
        /home/producao/mpich2/bin/mpiexec -n ${cores} /home/producao/PrevisaoPLD/shared/install/newave/newave_${ver}/Executaveis/newave${ver};
        echo -e "\n-----------[ Comprimindo alguns arquivos ] --------------"    
        { zip -q arq_bases arq_bases.bin && rm -f arq_bases.bin; } &
        { zip -q forward forward.dat && rm -f forward.dat; } &
        { zip -q cortese cortese.dat && rm -f cortese.dat; } &
        { zip -q energia energia*.dat && rm -f energia*.dat; } &
#        cp cortes-060.dat bkp-cortes-060.dat
        { zip -q etc alertainv_00* avl_* sgterm* newave_00*.log fpha_0*.svc eng*.dat vazinat.dat parp* \
            && rm -f alertainv_00* avl_* sgterm* newave_00*.log fpha_0*.svc eng*.dat vazinat.dat parp* ; } &
        wait;
#        mv bkp-cortes-060.dat cortes-060.dat
        echo -e "\n-----------[ Devolvendo resultados e excluindo pasta de trabalho ] --------------"
        cp -rf ./* "${origin_dir}";
        rm -rf "${work_dir}"
        #for xx in `tail -n+2 "${hostfile}" | grep -v '#' | cut -d":" -f1`; do ssh $xx "rm -rf $work_dir"; done
        cd "${origin_dir}"
        trap - EXIT SIGTERM TERM SIGINT SIGQUIT
#        mksquashfs cortes.dat cortes.squashfs -comp zstd && rm cortes.dat && touch cortes.dat
    fi;
    #construindo eafpast.dat
    if [ -f "pmo.dat" ]; then
        cut -c-4 ree.dat | tail -n+2 | head -n-1 > eafpast_a.dat
        sed -n "/ENERGIAS AFLUENTES PASSADAS PARA A TENDENCIA HIDROLOGICA/,/ENERGIAS AFLUENTES PASSADAS EM REFERENCIA/p" pmo.dat|tail -n+3|head -n $( wc -l<eafpast_a.dat )|cut -c2- > eafpast_b.dat
        paste -d" " eafpast_a.dat eafpast_b.dat > eafpast.dat
        rm eafpast_a.dat eafpast_b.dat vazinat.dat
    fi;
else
    echo -e "\n"
    echo "-----------[ Executando o Newave SIMULACAO FINAL ] --------------"
    /home/producao/PrevisaoPLD/shared/install/newave/newave_${ver}/Executaveis/newave${ver};
fi;
FIM=$(date)
echo -e "\n"
echo "Inicio da execucao       $INICIO"
echo "Fim da execucao          $FIM"
