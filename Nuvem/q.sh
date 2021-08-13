#!/bin/bash

#while true; do
#clear
#echo "$(date +%Y-%m-%d\ %T)"  
#ls -1 queue2/* |xargs -I% bash -c 'echo -e $(grep ^ord= % | cut -c5-10) "\e[93m%\e[0m" $(grep ^cmd= % | cut -d'/' -f8); grep ^dir= % | cut -d'/' -f6-20' 
#ls -1 running/* |xargs -I% bash -c 'echo -e  "\e[91m%\e[0m" $(grep ^cmd= % | cut -d'/' -f8) ; grep ^dir= % | cut -d'/' -f6-20'
#sleep 10
#done

function queue() {
	grep 'ord=' -HF queue/*|sort -t= -nrk2|cut -d: -f1|\
	xargs -I% bash -c 'echo -e "\e[93m"$(grep "^ord=" "%" |cut -c5-) "\t%\e[0m\t" $(grep "^cmd=" "%" |cut -d'/' -f8-); 
	echo -e "\e[95m"$(grep "^usr=" "%" |cut -c5-)"\e[0m\t" $(grep "^dir=" "%" |cut -d'/' -f6-)'
}

function running() {
	ls running/*|xargs -I% bash -c 'echo -e "\e[96m%\e[0m\t" $(grep "^cmd=" "%" |cut -d'/' -f8-);
	echo -e "\e[95m"$(grep "^usr=" "%" |cut -c5-)"\e[0m\t" $(grep "^dir=" "%" |cut -d'/' -f6-)'
}

function finished() {
	local n=${1:-5} 
	ls -t1 finished/*|head -n $n|xargs -I% bash -c 'echo -e $(grep "^EXIT" % |cut -d= -f2|\
	xargs -I{} bash -c '\''if [ {} -eq 0 ]; then echo "\e[32m{}"; else echo "\e[31m{}"; fi'\'')\
	"  \t%\e[0m\t" $(grep "^cmd=" "%" |cut -d'/' -f8-); 
	echo -e "\e[95m"$(grep "^usr=" "%" |cut -c5-)"\e[0m\t" $(grep "^dir=" "%" |cut -d'/' -f6-20)'
}

t=5
while true; do
	if [ -z $f ]; then
		s=$(queue;running;finished $n;date)
	else
		s=$(finished 100|tac;date)
	fi
	clear
	while read -r line; do
		echo "$line"
	done <<< "$s"
	read -s -t $t -n 1 k
	case $k in
		r) echo -n "n=";read n;;
		s) echo -n "stopped";read -s -n 1;;
		t) echo -n "time=";read t;;
		a) unset f;;
		f) f=1;;
	esac
done
