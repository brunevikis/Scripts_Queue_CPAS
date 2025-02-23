#!/bin/bash

par=$1
v="$(echo $0|sed -n 's/\(.*\/decomp\)\([0-9\.]*\)\(\_infinito.sh$\)/\2/p')"
gevazp=9.1.6

arqName=$( find . -maxdepth 1 -iname caso.dat -exec head -n 1 {} ';' | tr "[:upper:]" "[:lower:]" );
if [ -z "$arqName" ]; then
    echo -e "arquivo caso.dat nao encontrado ou vazio\n"
    exit 1
fi

echo "-----------[ Convertendo todos os arquivos para minusculas ]-----------";
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

/usr/bin/dos2unix "dadger.$arqName";
sed 's/CORTES\([-0-9]*\).DAT/cortes\1.dat/ig' "dadger.$arqName" | sed 's/CORTESH.DAT/cortesh.dat/g' > "dadger.$arqName.lower";
rm "dadger.$arqName";
mv "dadger.$arqName.lower" "dadger.$arqName";

cortesPath=$( grep cortes.dat "dadger.$arqName" | cut -c15- )

#if [ ! -f "$cortesPath" ]; then
#  echo "Cuts file does not exists"
#  exit 6;
#fi

#if file -bi "$cortesPath"|grep -q 'inode/x-empty'; then
#  if [ ! -f "${cortesPath/.dat/.squashfs}" ]; then
#    echo "Compressed cuts file not found"
#    exit 6;
#  fi
#  mpath="$(pwd)/cortes"
#  mkdir "$mpath"
#  squashfuse "${cortesPath/.dat/.squashfs}" "$mpath"
#  trap "umount ${mpath}" EXIT SIGTERM TERM SIGINT SIGQUIT
#  sed -i 's/\(^FC *NEWCUT.*\)\.dat/\&\1.dat\nFC  NEWCUT    cortes\/cortes.dat/' dadger.rv?
#fi

if [[ "$par" == "preliminar" ]]
then
   echo "/home/producao/PrevisaoPLD/enercore_ctl_common/scripts/FT/decomp.sh $v nao";
   /home/producao/PrevisaoPLD/enercore_ctl_common/scripts/FT/decomp.sh "$v" nao;
   ec=$?
else
   echo "/home/producao/PrevisaoPLD/enercore_ctl_common/scripts/FT/decomp.sh $v";
   /home/producao/PrevisaoPLD/enercore_ctl_common/scripts/FT/decomp.sh "$v" "$gevazp";
   ec=$?
fi

for (( ; ; )); do
   echo "/home/producao/PrevisaoPLD/enercore_ctl_common/scripts/FT/decomp.sh $v nao";
   /home/producao/PrevisaoPLD/enercore_ctl_common/scripts/FT/decomp.sh "$v" nao;
done

#if [ -z ${mpath+x} ]; then
#  umount "${mpath}"; rm -r "${mpath}"
#  trap - EXIT SIGTERM TERM SIGINT SIGQUIT
#  sed -i '/\(^FC *NEWCUT.*\)/d;s/^&\(FC *NEWCUT.*\)/\1/' dadger.rv?
#fi

exit $ec;