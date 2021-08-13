#!/bin/bash
cd ~
R --no-save <<RSCRIPT
library(shiny)
runApp("precip1",port=9988)
RSCRIPT
