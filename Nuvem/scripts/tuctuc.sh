#!/bin/bash
echo tuctuc
rv=$( find . -maxdepth 1 -iname caso.dat -exec head -n 1 {} ';' | tr "[:upper:]" "[:lower:]" )
dadger="dadger.$rv"
/usr/bin/dos2unix $dadger
[[ $(echo "$(grep "& NO. SEMANAS" "$dadger"|cut -c40-43)"-1|bc) -eq -1 ]] && exit
[[ "10#$(grep "& MES INICIAL" "$dadger"|cut -c40-42)" -lt 7 ]] && exit
[[ "10#$(grep "& MES INICIAL" "$dadger"|cut -c40-42)" -eq 12 ]] && exit
echo "& Restrição de Tucuruí feita pelo script" > hq
if [[ $(echo "$(grep "UH *275" "$dadger"|cut -c18-25)*389.82>=$(grep -m1 "LV *101" "$dadger"|cut -c25-)"|bc -l) -eq 1 ]]; then
  awk -v n="$(echo "$(grep "& NO. SEMANAS" "$dadger"|cut -c40-43)"-1|bc)" 'BEGIN{printf "HQ  333   1    %d\n", n} NR==1{split($0,a)} NR==2{split($0,b)} NR==3{split($0,c)} END{for(i=3;i<=n+2;i++) printf "LQ  333   %d   %10.1f%20.1f%20.1f\n", i-2, b[i]-a[i]-c[i], b[i]-a[i]-c[i], b[i]-a[i]-c[i]; printf "CQ  333   1   275           1     QDEF\nCQ  333   1   267          -1     QDEF\n"}' <(sed '/^\( *[0-9]*  \(275\|271\)\)/!d' "prevs.$rv";sed '/^TI *275/!d' "$dadger") >> hq
else
  awk -v n="$(echo "$(grep "& NO. SEMANAS" "$dadger"|cut -c40-43)"-1|bc)" 'BEGIN{printf "HQ  333   1    %d\n", n} NR==1{split($0,a)} NR==2{split($0,b)} NR==3{split($0,c)} END{for(i=3;i<=n+2;i++) printf "LQ  333   %d   %20.1f%20.1f%20.1f\n", i-2, b[i]-a[i]-c[i], b[i]-a[i]-c[i], b[i]-a[i]-c[i]; printf "CQ  333   1   275           1     QDEF\nCQ  333   1   267          -1     QDEF\n"}' <(sed '/^\( *[0-9]*  \(275\|271\)\)/!d' "prevs.$rv";sed '/^TI *275/!d' "$dadger") >> hq
fi
n=$(( 10#$(grep "& NO. SEMANAS" "$dadger"|cut -c40-43) ))
#cat hq
mv "$dadger" "dadger_bkp_tucurui.$rv"
#sed "/^[HLC]Q *333/d;/^& Restrição de Tucuruí feita pelo script/d" "dadger_bkp_tucurui.$rv" > temp
#sed "s/^HV *101.*/HV  101   $n    $(echo "$n+1"|bc)/g;s/^CV *101.*/CV  101   $n   275         1.0     VARM/g;/^LV *101   [^$n$(echo "$n+1"|bc)]/d;/$(grep '^CQ' temp|tail -1)/r hq" temp > "$dadger"
sed "s/^HV *101.*/HV  101   $n    $(echo "$n+1"|bc)/g;s/^CV *101.*/CV  101   $n   275         1.0     VARM/g;/^LV *101   [^$n$(echo "$n+1"|bc)]/d" "dadger_bkp_tucurui.$rv" > "$dadger"
rm hq #temp
