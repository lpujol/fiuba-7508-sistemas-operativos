#!/bin/bash

programname="prog1"

#Con Tipo de Mesaje y Numero
./loguearC.sh -w -t E101 -m "Algun error" -p $programname 

#Con Tipo de Mesaje normal
./loguearC.sh -w -t I -m "Informacion importante" -p "prog1" 

#Sin Mensaje
./loguearC.sh -w -t I -p "prog1" 

programname="prog2"
#Con Tipo de Mesaje y Numero
./loguearC.sh -w -t E101 -m "Algun error" -p $programname

#Read test
 ./loguearC.sh -t I    -p "prog1" -n 3

