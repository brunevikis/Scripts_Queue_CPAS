BEGIN{FS=" +; *";}{if($1==1&&$6!=11){a+=$5*($26>58.6?($26>751.73?751.73:$26):58.6);b+=$5;if($5=="-"){printf("pld%s=%s;%.2f;%s%%\n",$7,$26,a/b,$23);a=0;b=0}}}
