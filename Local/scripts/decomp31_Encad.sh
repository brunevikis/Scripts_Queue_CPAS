#!/bin/bash
LANG=en_US.utf8
comando="/home/producao/PrevisaoPLD/enercore_ctl_common/scripts/decomp31Viab.sh"
dir=$(pwd|rev|cut -d'/' -f1-2|rev)
n=$(($(echo $dir|cut -c16)+1))
nrev="$(pwd|rev|cut -d'/' -f3-|rev)/rv$(($(echo $dir|cut -c3)+1))"
next="$(echo $(echo $dir|cut -c5-15)$n$(echo $dir|cut -c17-)|sed 's/CV1/CV2_/g;s/VIES_VE/GEFS/g')"
echo $INICIO
echo ""
echo "$dir"
echo "$comando"
$comando
ec=$? 
if [[ $ec != 0 ]]
then
    exit $ec;
fi
    if [[ -d "$nrev/deck" ]]
    then
    cp -r "$nrev/deck" "$nrev/$next"
    echo /home/producao/PrevisaoPLD/enercore_ctl_common/scripts/buscaEarm_dc_dc.sh "$(pwd)" "$nrev/$next"
    /home/producao/PrevisaoPLD/enercore_ctl_common/scripts/buscaEarm_dc_dc.sh "$(pwd)" "$nrev/$next"
    echo "AGENDAR NOVA EXECUCAO"
    dt=$(date +%Y%m%d%H%M%S)
    ord=$(( 10 ))
    usr="encad"
    fn="/home/producao/PrevisaoPLD/enercore_ctl_common/waiting_prevs/$next"
    cmd="$0"
    printf -v newComm "%s\n" "ord=${ord}" "usr=${usr}" "dir=$nrev/$next" "cmd=${cmd}" "ign=False" "cluster="
    echo ""
    echo "$newComm"
    echo "$newComm" > ${fn}
fi
exit 0;
