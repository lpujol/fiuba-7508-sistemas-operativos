#! /bin/bash            
#
#
# loguer.sh
# Script parar crear logs
#
# de Nikolaus Schneider para el trabajo practico
# de la MAteria Sistemas Operativos
#
# last change: 2011-09-25

echo Vamos!


# Parameter parsen
echo parse
while getopts a:b option
do	
case "$option" in
	a)	echo $OPTARG;;
	b)	echo Parm B;;
	[?])	echo "Usage: bbbb"
	esac
done






#Parameterreihenfolge?
