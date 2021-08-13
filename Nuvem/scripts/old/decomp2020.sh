#!/bin/bash

# script para execucao do decomp

ver=$1
gevazp=$2

hostfile="/home/producao/PrevisaoPLD/cpas_ctl_common/hosts/$( hostname ).hosts.mpi"
cores=0

for nx in $( cat $hostfile | cut -d":" -f2 ); do cores=$(( $cores + $nx )); done


echo "versão         : $ver"
echo "# cores        : $cores"
echo "$( cat $hostfile )"
echo "gevazp          : $gevazp"


INICIO=$(date);

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
rm -f *.csv;
rm -f qsinp*;
rm -f qsout*;
rm -f relato.rv*;
rm -f sumario.rv*;
rm -f relato_adic.zip;
rm -f csv.zip;
rm -f runtrace.dat;

echo -e "\n";

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

echo $arqName;

if [ -f "perdas.dat" ]; then 
lossfile="perdas.dat"
fi

if [ -f "loss.dat" ]; then
lossfile="loss.dat"
fi


echo "-----------[ Duplica arquivo $arqName para decomp.arq ]-------";
/usr/bin/dos2unix $arqName;
cp $arqName decomp.arq;

head -n 6 decomp.arq > $arqName
echo "/home/producao/PrevisaoPLD/shared/install/decomp/${ver}/Executaveis/" >> $arqName;

echo -e "\n";

echo "-----------[ Executando ConverteNomesArquivosDecomp${ver} -----------";
/home/producao/PrevisaoPLD/shared/install/decomp/${ver}/Executaveis/convertenomesdecomp_${ver};
echo -e "\n";

echo "Convertendo tudo em caso.dat para minusculas";
sed -e 's/\(.*\)/\L\1/' caso.dat > caso.dat.tmp;
rm caso.dat;
mv caso.dat.tmp caso.dat;

echo -e "\n";


if [ ! "$gevazp" == "nao" ]; then
    rm -f vazoes.$arqName;
    
    if [ ! -f vazoes.$arqName ]; then
        echo "Arquivo de vazoes não encontrado, executando gevazp.";
        echo -e "\n";
    
        /home/producao/PrevisaoPLD/cpas_ctl_common/scripts/gevazp2020.sh   
        
        if [ ! -f vazoes.$arqName ]; then
            echo -e "\n";
            echo "Falha ao executar gevazp!"; 
            exit 1;
        fi
    fi
fi

echo "Convertendo CORTES.DAT e CORTESH.DAT para minusculas, dentro do arquivo dadger.$arqName";
cat dadger.$arqName | sed 's/CORTES.DAT/cortes.dat/g' | sed 's/CORTESH.DAT/cortesh.dat/g' > dadger.$arqName.lower;
rm dadger.$arqName;
mv dadger.$arqName.lower dadger.$arqName;



# loss.dat é o ultimo arquivo conferido, então o sacrifico para vefiricar os demais.
echo -e "\n";
echo "-----------[ Checando dados de Entrada ]-----------";
mv $lossfile _$lossfile

echo "/home/producao/PrevisaoPLD/shared/install/decomp/${ver}/Executaveis/decomp_${ver}  > /dev/null 2>&1"
/home/producao/PrevisaoPLD/shared/install/decomp/${ver}/Executaveis/decomp_${ver}  > /dev/null 2>&1

oks=$( cat relato.$arqName | grep OK! | wc -l );

rm -f $lossfile
mv _$lossfile $lossfile


if [ $oks -ne 5 ]; then #deve conter 5 x OK!.. vazoes, dadger, dadgnl, hidr e  mlt

    echo -e "\n";
    echo "PROCESSAMENTO INTERROMPIDO DEVIDO A ERRO(S) DE ENTRADA DE DADOS"
    echo -e "\n";    
    echo "*** VER LISTA DE ERROS NO ARQUIVO relato.${arqName}"

    exit 1;
fi



arqcsv=$( grep "^IR  ARQCSV" dadger.$arqName );
#adicionar ARQCSV se não existir
if [ -z "$arqcsv" ]; then
    sed -e '/^IR  GRAFICO/aIR  ARQCSV' dadger.$arqName -i
fi 




echo -e "\n";
echo "-----------[ Executando o DECOMP atraves do comando deco${ver} ]-----------";
echo "/opt/aplicacoes/mpich-3.1.4/install/bin/mpiexec -f ${hostfile} -n ${cores} /home/producao/PrevisaoPLD/shared/install/decomp/${ver}/Executaveis/decomp_${ver}";
/opt/aplicacoes/mpich-3.1.4/install/bin/mpiexec -f "${hostfile}" -n ${cores} /home/producao/PrevisaoPLD/shared/install/decomp/${ver}/Executaveis/decomp_${ver}

echo -e "\n";
echo "Fim da execucao       $FIM" >> decomp_tempos.log;
echo "------------------------------------------------------" >> decomp_tempos.log;
echo -e "\n";

exCode=0

gapnegativo=$( grep "GAP NEGATIVO" relato.$arqName | wc -l );
erronorelato=$( grep "ERRO(S) DE ENTRADA DE DADOS" relato.$arqName | wc -l );

# Tentativa de identificar o erro do C5

if [ ! -s "sumario.$arqName" ]; then

    echo -e "\n";
#    echo "-----------[**********    C5 ataca novamente   **************]-----------"

    exCode=5;
fi
# Tentativa de identificar o erro do C5

if [ $gapnegativo -gt 0 ]; then

    echo -e "\n";
    echo "-----------[**********    GAP NEGATIVO   **************]-----------"

    exCode=7;
fi


if [ $erronorelato -gt 0 ]; then

    echo -e "\n";
    echo "-----------[**********    ERRO(S) DE ENTRADA DE DADOS   **************]-----------"

    exCode=1;
fi


echo -e "\n";
echo "-----------[ Comprimindo saidas secundárias ]-----------";
echo "                  *fpha[._]* relato2.* memcal.* mapcut.* custos.* fcfnwn.* *.csv;";

#keep oper_sist
if [ -f "dec_oper_sist.csv" ]; then
    cp dec_oper_sist.csv dec_oper_sist._sv
fi

relato_adic2="*fpha[._]* relato2.* memcal.* mapcut.* custos.* fcfnwn.*";
zip -q relato_adic ${relato_adic2} && rm -f ${relato_adic2};
zip -q csv *.csv && rm -f *.csv;


if [ -f "dec_oper_sist._sv" ]; then
    mv dec_oper_sist._sv dec_oper_sist.csv
fi

FIM=$(date);

echo "Inicio da execucao    $INICIO";
echo "Fim da execucao       $FIM";

exit $exCode;









