#!/bin/bash

Msg=$1


echo -e "$Msg" | mail -A cpas -s "$2" alex.marques@cpas.com.br




