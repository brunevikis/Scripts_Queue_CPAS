#!/bin/bash


#DECOMP

#echo "Iniciando Instalação"
cd /home/producao/PrevisaoPLD/shared/install/decomp
cp * /opt/aplicacoes/decomp/bin/

#NEWAVE

cd /home/producao/PrevisaoPLD/shared/install/newave

ls -1 /usr/bin > A.x

response=$( find . -type f -iname newave*.csh -exec csh "{}" \; )

if [ -z "$( echo $response | grep "sucesso" | grep "/usr/bin" )" ]
then
    echo "*** Ocorreu algum erro na instalação, verifique"
    echo "resposta do csh: $response"
    exit 2
fi 

ls -1 /usr/bin > B.x

arquivos="$( diff A.x B.x | grep ">" | cut -d'>' -f2 )"

echo ""
echo "*** Arquivos instalados em /usr/bin: "
echo "$arquivos"

for f in $arquivos
do    
    ft="/usr/bin/$f"
    echo "copiando o arquivo /usr/bin/$f"
    mv $ft /opt/aplicacoes/newave/bin/
done

rm -f A.x
rm -f B.x

#versao="2302" #buscar da pasta ou dos arquivos copiados.
#arqScript="newave$versao.sh"

#echo '#!/bin/bash' > "$arqScript"
#echo '' >> "$arqScript"
#echo 'echo "/home/producao/PrevisaoPLD/cpas_ctl_common/scripts/newave.sh' $versao '40 0";' >> "$arqScript"
#echo '/home/producao/PrevisaoPLD/cpas_ctl_common/scripts/newave.sh' $versao '40 0;' >> "$arqScript"


echo "Fim da Instalção"
