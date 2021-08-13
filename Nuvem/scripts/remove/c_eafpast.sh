#!/bin/bash

#read ree.dat

cut -c-4 ree.dat | tail -n+2 | head -n-1 > eafpast_a.dat

cat pmo.dat | sed -n "/ENERGIAS AFLUENTES PASSADAS PARA A TENDENCIA HIDROLOGICA/,/ENERGIAS AFLUENTES PASSADAS EM REFERENCIA/p" | tail -n+3 | head -n $( cat eafpast_a.dat | wc -l ) | cut -c2- > eafpast_b.dat

paste -d" " eafpast_a.dat eafpast_b.dat > eafpast.dat


rm eafpast_a.dat eafpast_b.dat

