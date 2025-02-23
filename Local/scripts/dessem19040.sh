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


dessemPath="/home/producao/PrevisaoPLD/shared/install/dessem/dessem_19.0.40/Executaveis/dessem_19.0.40"
${dessemPath}
ec=$?


cp -f * "${origin_dir}";
wait;
rm -rf ${work_dir};

exit $ec;