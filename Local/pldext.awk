BEGIN{FS=" +; *"}{if($1==$2&&$5!=11){a+=$4*($24>55.70?($24>646.58?646.58:$24):55.70);b+=$4;if($4=="-"){sub("/dec_oper_sist.csv","",FILENAME);sub(x,"",FILENAME);printf("%s;%s;%s;%s;%.2f;%s%%;\n",FILENAME,$1,$6,$24,a/b,$21);a=0;b=0}}}
