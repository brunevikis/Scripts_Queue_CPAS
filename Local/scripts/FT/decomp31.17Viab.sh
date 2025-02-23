#!/bin/bash
 export LC_ALL=C.UTF-8
par=$1
v="$(echo $0|sed -n 's/\(.*\/decomp\)\([0-9\.]*\)\([[:alnum:]_]*\.sh$\)/\2/p')"
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
sed 's/CORTES.DAT/cortes.dat/g' "dadger.$arqName" | sed 's/CORTESH.DAT/cortesh.dat/g' > "dadger.$arqName.lower";
rm "dadger.$arqName";
mv "dadger.$arqName.lower" "dadger.$arqName";

cortesPath=$( grep cortes.dat "dadger.$arqName" | cut -c15- )

if [ ! -f "$cortesPath" ]; then
  echo "Cuts file does not exists"
  exit 6;
fi

if file -bi "$cortesPath"|grep -q 'inode/x-empty'; then
  if [ ! -f "${cortesPath/.dat/.squashfs}" ]; then
    echo "Compressed cuts file not found"
    exit 6;
  fi
  mpath="$(pwd)/cortes"
  mkdir "$mpath"
  squashfuse "${cortesPath/.dat/.squashfs}" "$mpath"
  trap "umount ${mpath}" EXIT SIGTERM TERM SIGINT SIGQUIT
  sed -i 's/\(^FC *NEWCUT.*\)\.dat/\&\1.dat\nFC  NEWCUT    cortes\/cortes.dat/' dadger.rv?
fi

sed -i ':a;s/\(^   226  226[ 1]*\)0/\11/;ta' prevs.rv?
sed -i ':a;s/\(^   260  260[ 1]*\)0/\11/;ta' prevs.rv?
sed -i ':a;s/\(^    88   88[ 1]* 1\)         0/\11/;ta' prevs.rv?
if pwd|grep -q '_NWh_'; then
  grep -q '^UH  309' dadger.rv? || sed -i '/^&UH *$/a UH  309                                                                NW' dadger.rv?
  grep -q '^UH   88' dadger.rv? || sed -i '/^&UH *$/a UH   88                                                                NW' dadger.rv?
  if grep -q '^DT.*2024$' dadger.rv?; then
    grep -q '^UH  260' dadger.rv? || sed -i '/^&UH *$/a UH  260                                                                NW' dadger.rv?
  fi
  if grep -q '^UH  146' dadger.rv?;then
      grep -q '^CX  ' dadger.rv? || sed -i '/^FC  NEWCUT/a CX  176  173\nCX  176  174\nCX  176  175\nCX  132  146\nCX  132  147' dadger.rv?
  else
      grep -q '^CX  ' dadger.rv? || sed -i '/^FC  NEWCUT/a CX  176  173\nCX  176  174\nCX  176  175\nCX  132  183\nCX  132  184' dadger.rv?
  fi
fi

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

if [ $ec == 0 ]||[ $ec == 7 ]||[ $ec == 5 ]
then
  arq=$( cat caso.dat ) 
  if [ ! -f "sumario.$arq" ]
  then
    echo -e "\nRemovendo Inviabilidades\n"
    rm -f relato.bkp
    cp -pf ./relato.* ./relato.bkp
    /usr/bin/dotnet "/home/producao/PrevisaoPLD/shared/price_tools/inviab/bin/Release/netcoreapp3.1/TrataInviab.dll" 1
    /usr/bin/dotnet /home/producao/PrevisaoPLD/shared/price_tools/inviab/bin/Release/netcoreapp3.1/TrataInviab.dll "flexTucurui"
    sed -i 's/^UH  309$/UH  309                                                                NW/g' dadger.rv?
    sed -i 's/^UH   88$/UH   88                                                                NW/g' dadger.rv?
    #if grep -q '^UH  146' dadger.rv?;then
    #    grep -q '^CX  ' dadger.rv? || sed -i '/^FC  NEWCUT/a CX  176  173\nCX  176  174\nCX  176  175\nCX  132  146\nCX  132  147' dadger.rv?
    #else
    #    grep -q '^CX  ' dadger.rv? || sed -i '/^FC  NEWCUT/a CX  176  173\nCX  176  174\nCX  176  175\nCX  132  183\nCX  132  184' dadger.rv?
    #fi
    echo "/home/producao/PrevisaoPLD/enercore_ctl_common/scripts/FT/decomp.sh $v nao";
    /home/producao/PrevisaoPLD/enercore_ctl_common/scripts/FT/decomp.sh "$v" nao;
    ec=$?
    if [ ! -f "sumario.$arq" ]
    then
      echo -e "\nRemovendo Inviabilidades - segunda iteracao\n"
      rm -f relato.bkp
      cp -pf ./relato.* ./relato.bkp
      /usr/bin/dotnet "/home/producao/PrevisaoPLD/shared/price_tools/inviab/bin/Release/netcoreapp3.1/TrataInviab.dll" 3
      /usr/bin/dotnet /home/producao/PrevisaoPLD/shared/price_tools/inviab/bin/Release/netcoreapp3.1/TrataInviab.dll "flexTucurui"
      sed -i 's/^UH  309$/UH  309                                                                NW/g' dadger.rv?
      sed -i 's/^UH   88$/UH   88                                                                NW/g' dadger.rv?
      #if grep -q '^UH  146' dadger.rv?;then
      #  grep -q '^CX  ' dadger.rv? || sed -i '/^FC  NEWCUT/a CX  176  173\nCX  176  174\nCX  176  175\nCX  132  146\nCX  132  147' dadger.rv?
      #else
      #  grep -q '^CX  ' dadger.rv? || sed -i '/^FC  NEWCUT/a CX  176  173\nCX  176  174\nCX  176  175\nCX  132  183\nCX  132  184' dadger.rv?
      #fi
      echo "/home/producao/PrevisaoPLD/enercore_ctl_common/scripts/FT/decomp.sh $v nao";
      /home/producao/PrevisaoPLD/enercore_ctl_common/scripts/FT/decomp.sh "$v" nao;
      ec=$?
    fi
  fi
fi

if [ $ec -eq 7 ]; then 
  echo " Tratar gap negativo "
  sed -i '/^FJ/a RT  CRISTA' "dadger.$arqName"
  sed -i '/^FA/a RT  CRISTA' "dadger.$arqName"
  /home/producao/PrevisaoPLD/enercore_ctl_common/scripts/FT/decomp.sh "$v" nao;
  ec=$?
fi

if [ -z ${mpath+x} ]; then
  umount "${mpath}"; rm -r "${mpath}"
  trap - EXIT SIGTERM TERM SIGINT SIGQUIT
  sed -i '/\(^FC *NEWCUT.*\)/d;s/^&\(FC *NEWCUT.*\)/\1/' dadger.rv?
fi

if [ ! -f "sumario.$arq" ] && [ $ec -eq 0 ]
then
  echo "  !!!!!!!!!!!!!!!!!!!!!!  "
  echo "  falha na convergencia   "
  echo "  !!!!!!!!!!!!!!!!!!!!!!  "
  ec=2
fi

exit $ec;