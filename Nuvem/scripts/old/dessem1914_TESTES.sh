#!/bin/bash

# script para execucao do dessem


origin_dir=$(pwd)

#definir diretorio para processamento 
if [ ! -d /mnt/resource/dessem ]; then
    sudo mkdir -p  -m 777 /mnt/resource/dessem
fi

work_dir=/mnt/resource/dessem/$(date +%Y%m%d%H%M%s%N)/

echo "-----------[ Copiando deck para pasta de processamento ] --------------"
echo cp -rp "${origin_dir}" "${work_dir}"

cp -rp "${origin_dir}" "${work_dir}"
wait;

cd "${work_dir}"
echo "/usr/bin/dos2unix entdados.dat"
/usr/bin/dos2unix entdados.dat
echo "/usr/bin/dos2unix dessem.arq"
/usr/bin/dos2unix dessem.arq
echo "executou dos2unix"
dessemPath="/home/compass/sacompass/previsaopld/shared/install/dessem/dessem_19.0.14.1/Executaveis/dessem_19.0.14.1"
${dessemPath}
ec=$?


cp -f * "${origin_dir}";
wait;
rm -rf ${work_dir};

exit $ec;