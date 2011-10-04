#!/bin/bash
# detectarC

# Trap para QUIT signal (3)
trap 'exit' 1 # Acá habría que hacer algo más
trap 'exit' 3 # Acá habría que hacer algo más
#ps ux | awk '/detectar/ && !/awk/ {print $2}'

# Variables
ARRIBDIR=/home/juani/Desktop/SO/ARRIBDIR
PID_FILE=/home/juani/Desktop/SO/detectarC.pid
LOG_FILE=/home/juani/Desktop/SO/detectarC.log
MAEENC=/home/juani/Desktop/SO/encuestadores.mae

> $LOG_FILE # Creo (o vacio) el archivo de log
cd $ARRIBDIR
echo $$ > $PID_FILE
# Tiene que correr indefinidamente
COUNTER=1
while [ $COUNTER -eq 1 ]; do
	# Por cada archivo del directorio actual
	for file in `find . -type f -maxdepth 1 -print 2>/dev/null`; do
		if echo $file | grep -Eq '^\./(19|20)[0-9][0-9](0[1-9]|1[0-2])(0[1-9]|[1-2][0-9]|3[01])\.\w{8}$' 
		then
			# El FORMATO es valido (todavia hay que chequear que sea valida la 
			# fecha y el userid
			USERID_ENTRANTE=`echo $file | cut -d . -f 3`
			ENCONTRADO=0
			exec < $MAEENC
			while read linea; do
				if [ $USERID_ENTRANTE = `echo $linea | cut -b 1-8` ]; then
					ENCONTRADO=1
				fi
			done
			if [ $ENCONTRADO -eq 1 ]; then
				echo "Archivo aceptado: $file" >> $LOG_FILE
			else
				echo "Archivo rechazado: $file" >> $LOG_FILE
			fi
		else
			echo "Archivo rechazado: $file" >> $LOG_FILE
		fi
	done
	sleep 30
done
