#!/bin/bash

LANG=en_US.utf8

ln=$( grep "ENERGIA ARMAZENADA INICIAL" "pmo.dat" -n | cut -d':' -f1 )
IFS=' ' read -r -a array <<< $( tail pmo.dat -n+$ln | head -n4 | tail -n1 | tr - 0 )
echo array "${array[@]}"
	
   