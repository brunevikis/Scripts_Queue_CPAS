#!/bin/bash
exit
encadPath=$(pwd)

am=$(ls | grep -E '^20[0-9]{4}')
dcPaths=$(ls | grep -E '^20[0-9]{4}' -v)
for anomes in $am ; do
  echo "$anomes"
  ano=${anomes:0:4}
  mes=${anomes:4:2}
  mesN=$(printf '%02d' $(( 10#0$mes+1 )))
  anoN=$ano
  if [[ "$mesN" == "13" ]]; then
    mesN="01"
    anoN=$(( $anoN + 1 ))
  fi
  for dc in $dcPaths ; do
    if [ -d "./$dc/$anoN$mesN" ]; then
      dadger=$(find "./$dc/$anoN$mesN" -iname 'dadger.rv?')
      mv "$dadger" "./$dc/$anoN$mesN/dadger.errado"
      mv "./$dc/$anoN$mesN/dadger.bkp" "$dadger"
    fi
  done
  cd "$anomes"
  confhd=$(find ../$anoN$mesN/ -iname "confhd.dat")
  mv "../$anoN$mesN/confhd.bkp" "$confhd"
  curl --get --data-urlencode "path=$encadPath" --data-urlencode "date=$ano$mes" "http://10.206.194.210/api/encad/encad_nwlistop"
  mv "$confhd" "../$anoN$mesN/confhd.bkp" && mv "${confhd}.earm" "$confhd"
  for dc in $dcPaths ; do
    if [ -d "../$dc/$anoN$mesN" ]; then
      dadger=$(find "../$dc/$anoN$mesN" -iname 'dadger.rv?')
      nn=$(sed -n "s/^& NO. DIAS DO MES 2 NA ULT. SEMANA *=> *\([0-9]*\)/\1/p" ${dadger})
      if [[ ${nn:0-2:1} -eq 0 ]]; then
        nn=0
      else
        nn=1
      fi
      q=$(sed -n "s/^& NO. SEMANAS NO MES INIC. DO ESTUDO=> *\([0-9]*\) \([0-9]*\)/\1/p" ${dadger})
      nn=$(( ${q:0-2:1}-$nn ))
      [[ nn -eq 0 ]] && nn=1;
      mv "$dadger" "../$dc/$anoN$mesN/dadger.bkp"
      awk -v n=$n -v m=$mesN -v nn=$nn -f "/home/producao/PrevisaoPLD/enercore_ctl_common/awk/2024/SF+Paranapanema/dadger_hibrido_nwmeta.awk"  "$confhd" "${dadger}.earm" > "$dadger"
      rm "$dadger.earm"
    fi
  done
  cd "${encadPath}"
done