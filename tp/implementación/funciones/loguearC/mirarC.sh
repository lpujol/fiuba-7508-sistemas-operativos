#! /bin/bash            
#
# mirar.sh
# Script parar mirar logs
#
# de Nikolaus Schneider para el trabajo practico
# de la Materia Sistemas Operativos
#
# last change: 2011-10-16

#Códigos de retorno
	#  0 - Esta bien
	#  1 - Faltan Parametros
	#  3 - Ambiente no iniciado
	#  4 - Parametro inválido
	#  5 - Archivo de log no existente


./loguearC.sh -v $1 $2 $3 $4 $5 $6 $7 $8

exit $?
