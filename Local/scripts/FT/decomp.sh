#!/bin/bash

# script para execucao do decomp

ver=$1
gevazp=$2
[ -z "$2" ] && gevazp="9"
#hostfile="/home/producao/PrevisaoPLD/enercore_ctl_common/hosts/$( hostname ).hosts.mpi"
#cores=0
#for nx in $(cut -d":" -f2 "$hostfile"); do cores=$(( cores + nx )); done
cores=13
echo "versão         : $ver"
echo "# cores        : $cores"
#cat "$hostfile"
echo "gevazp          : $gevazp"

INICIO=$(date);

keepcsv=( indices indices_gevazp hist-ventos pee-cad pee-cadastro pee-config pee-fte pee-geracao pee-posto pee-submercado posto-cadastro polinjus parque_eolico_cadastro parque_eolico_config parque_eolico_fte parque_eolico_geracao parque_eolico_pot_instalada parque_eolico_subm)
for i in ${keepcsv[@]}; do
  [ -f "${i}.csv" ] && mv "${i}.csv" "${i}._sv"
done
touch isca;
shopt -s extglob;
echo "Inicio da execucao    $INICIO" >> decomp_tempos.log;
echo "-----------[ Limpando boa parte da sujeira ]-----------";
rm -f cortdeco_*;
rm -f osl_*.rel;
rm -f inviab_*.rv?;
rm -f dimpl_*.rv?;
rm -f debug_*.rv?;
rm -f cad*.rv?;
rm -f ./*.csv;
rm -f qsinp*;
rm -f qsout*;
rm -f relato.rv*;
rm -f sumario.rv*;
rm -f relato_adic.zip;
rm -f csv.zip;
rm -f mapcut.*
rm -f custos.*
rm -f etc.zip
#rm -f runtrace.dat;
for i in ${keepcsv[@]}; do
  [ -f "${i}._sv" ] && mv ${i}._sv ${i}.csv
done

echo -e "\n-----------[ Convertendo todos os arquivos para minusculas ]-----------";
for i in $( ls -p | grep '/$' -v ); do
    AUXLOWER=$(echo "$i" | tr "[:upper:]" "[:lower:]");
    if [ ! "$i" == "$AUXLOWER" ]; then
        echo -n "Convertendo $i para $AUXLOWER ... ";
        mv "$i" "$AUXLOWER";
        if [ -f "$AUXLOWER" ]; then
            echo "ok";
        else
            echo "erro";
        fi
    fi
done
/usr/bin/dos2unix caso.dat;
arqName=$( find . -maxdepth 1 -iname caso.dat -exec head -n 1 {} ';' | tr "[:upper:]" "[:lower:]");
if [ -z "$arqName" ]; then
    echo -e "arquivo caso.dat nao encontrado ou vazio\n"
    exit 1
fi
echo "$arqName";

lossfile=$( grep "^\(loss\)\|\(perdas\)" "${arqName}" )

echo "-----------[ Duplica arquivo $arqName para decomp.arq ]-------";
/usr/bin/dos2unix "$arqName";
cp "$arqName" decomp.arq;
echo -e "\n";

echo "-----------[ Executando ConverteNomesArquivosDecomp${ver} -----------";
/home/producao/PrevisaoPLD/shared/install/decomp/${ver}/Executaveis/convertenomesdecomp_${ver};
echo -e "\n";
echo "Convertendo tudo em caso.dat para minusculas";
sed -e 's/\(.*\)/\L\1/' caso.dat > caso.dat.tmp;
rm caso.dat;
mv caso.dat.tmp caso.dat;
echo -e "\n";

head -n 7 decomp.arq > "$arqName"
echo "/home/producao/PrevisaoPLD/install/decomp/${ver}/Executaveis/" >> "$arqName";
echo -e "\n";

if [ ! "$gevazp" == "nao" ]; then
    rm -f "vazoes.$arqName";
    if [ ! -f "vazoes.$arqName" ]; then
      if [ -f indices.csv ] && [ -f indices_gevazp.csv ]; then
        mv indices.csv indices_decomp.csv
        mv indices_gevazp.csv indices.csv
        indices=TRUE
      fi
      if [ -f indices.csv ] && [ ! -f polinjus.csv ] && [ -f polinjus.dat ]; then
          awk -f /home/producao/PrevisaoPLD/enercore_ctl_common/awk/polinjus.awk polinjus.dat > polinjus.csv
      fi
      echo "Arquivo de vazoes não encontrado, executando gevazp.";
      echo -e "\n";
      /home/producao/PrevisaoPLD/enercore_ctl_common/scripts/FT/gevazp.sh "$gevazp"
      err=$?
      if [ $indices ]; then
        mv indices.csv indices_gevazp.csv
        mv indices_decomp.csv indices.csv
      fi
      if [ ! -f "vazoes.$arqName" ]||[ $err -ne 0 ]; then
          echo -e "\nFalha ao executar gevazp!"; 
          exit 3;
      fi
    fi
fi

echo "Convertendo CORTES.DAT e CORTESH.DAT para minusculas, dentro do arquivo dadger.$arqName";
sed 's/CORTES.DAT/cortes.dat/g' "dadger.$arqName" | sed 's/CORTESH.DAT/cortesh.dat/g' > "dadger.$arqName.lower";
rm "dadger.$arqName";
mv "dadger.$arqName.lower" "dadger.$arqName";

# loss.dat é o ultimo arquivo conferido, então o sacrifico para vefiricar os demais.
echo -e "\n-----------[ Checando dados de Entrada ]-----------";
mv "$lossfile" "_$lossfile"

echo "/home/producao/PrevisaoPLD/shared/install/decomp/${ver}/Executaveis/decomp_${ver}  > /dev/null 2>&1"
/home/producao/PrevisaoPLD/shared/install/decomp/${ver}/Executaveis/decomp_${ver}  > /dev/null 2>&1

oks=$( grep -c OK! "relato.$arqName" );

rm -f "$lossfile"
mv "_$lossfile" "$lossfile"

if [ "$oks" -ne 5 ]; then #deve conter 5 x OK!.. vazoes, dadger, dadgnl, hidr e  mlt
    echo -e "\n";
    echo "PROCESSAMENTO INTERROMPIDO DEVIDO A ERRO(S) DE ENTRADA DE DADOS"
    echo -e "\n";    
    echo "*** VER LISTA DE ERROS NO ARQUIVO relato.${arqName}"
    grep "ERRO:" "relato.$arqName"
    exit 1;
fi

arqcsv=$( grep "^IR  ARQCSV" "dadger.$arqName" );
#adicionar ARQCSV se não existir
if [ -z "$arqcsv" ]; then
    sed -e '/^IR  GRAFICO/aIR  ARQCSV' "dadger.$arqName" -i
fi 

echo -e "\n-----------[ Executando o DECOMP atraves do comando deco${ver} ]-----------";
echo "/home/producao/mpich2/bin/mpiexec -f ${hostfile} -n ${cores} /home/producao/PrevisaoPLD/shared/install/decomp/${ver}/Executaveis/decomp_${ver}";
/home/producao/mpich2/bin/mpiexec -n ${cores} /home/producao/PrevisaoPLD/shared/install/decomp/${ver}/Executaveis/decomp_${ver}

echo "Fim da execucao       $FIM" >> decomp_tempos.log;
echo "------------------------------------------------------" >> decomp_tempos.log;
echo -e "\n";

exCode=0

gapnegativo=$( grep -c "GAP NEGATIVO" "relato.$arqName" );
erronorelato=$( grep -c "ERRO(S) DE ENTRADA DE DADOS" "relato.$arqName" );

## Tentativa de identificar o erro do C5
#
#if [ ! -s "sumario.$arqName" ]; then
#
#    echo -e "\n";
##    echo "-----------[**********    C5 ataca novamente   **************]-----------"
#
#    exCode=5;
#fi
## Tentativa de identificar o erro do C5

if [ "$gapnegativo" -gt 0 ]; then
    echo "-----------[**********    GAP NEGATIVO   **************]-----------"
    exCode=7;
fi

if [ $erronorelato -gt 0 ]; then
    echo "-----------[**********    ERRO(S) DE ENTRADA DE DADOS   **************]-----------"
    echo "$( grep "ERRO:" relato.$arqName )"
    exCode=1;
fi
echo "-----------[ Comprimindo saidas secundárias ]-----------";
echo "                  *fpha[._]* relato2.* memcal.* mapcut.* custos.* fcfnwn.* *.csv;";

#keep oper_sist
if [ -f "dec_oper_sist.csv" ]; then
    cp dec_oper_sist.csv dec_oper_sist._sv
	cp bengnl.csv bengnl._sv
fi

for i in ${keepcsv[@]}; do
  [ -f "${i}.csv" ] && mv "${i}.csv" "${i}._sv"
done
rm -f memcal.*;
#relato_adic2="*fpha[._]* relato2.* memcal.* mapcut.* custos.* fcfnwn.*";
#relato_adic2="*fpha[._]* relato2.* memcal.* fcfnwn.*";
relato_adic2="*fpha[._]* relato2.* fcfnwn.*";
zip -q9 relato_adic ${relato_adic2} && rm -f ${relato_adic2};
zip -q9 csv *.csv && rm -f *.csv;

if [ -f "dec_oper_sist._sv" ]; then
    mv dec_oper_sist._sv dec_oper_sist.csv
	mv bengnl._sv bengnl.csv
fi
for i in ${keepcsv[@]}; do
  [ -f "${i}._sv" ] && mv ${i}._sv ${i}.csv
done

zip -q9 etc custos.rv? mapcut.rv? cortdeco.rv? energia.rv? cusfut.rv? cad0* dimpl_* *.msg && rm custos.rv? mapcut.rv? cortdeco.rv? energia.rv? cusfut.rv? cad0* dimpl_* *.msg

FIM=$(date);

echo "Inicio da execucao    $INICIO";
echo "Fim da execucao       $FIM";

exit $exCode;
