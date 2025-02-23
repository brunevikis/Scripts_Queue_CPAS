#!/bin/bash
origin_dir=$(pwd)
remover="keep"

if [ -n "$1" ]
then
	remover=$1
	echo "$remover"
		if [ "$remover" = "del" ]
		then
			echo "os diretorios serão apagados ao final da compactação"
			else
			echo "os diretorios serão mantidos ao final da compactação"
		fi
else
	echo "os diretorios serão mantidos ao final da compactação"
fi


for di in $(find . -mindepth 1 -maxdepth 1 -type d | cut -f2 -d "/" ) ; do

	if [ -d "$di" ]; then

		diretorio=$(echo $origin_dir/$di)

		if [ ! "$diretorio" == "" ];
		then
			if [ ! -f "$di.tar.gz" ]
			then
				echo "Compactando $diretorio"

				tar -czf "$di.tar.gz" "$di"
				echo "compactado"
				
				if [ "$remover" = "del" ]
				then
					echo "removendo $di"
					rm -r "$di"
				fi
			else
				echo "$di.tar.gz ja existe"
			fi
		fi
	fi
done
