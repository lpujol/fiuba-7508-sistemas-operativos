#!/bin/bash
# detectarC

# Trap para QUIT signal (3) y KILL (1)
trap 'exit' 1 # Acá habría que hacer algo más?
trap 'exit' 3 # Acá habría que hacer algo más?
#ps ux | awk '/detectar/ && !/awk/ {print $2}'

# Variables
DIR_ARRIBOS="arribos"
PID_FILE=".detectarC.pid"
MAEENC="encuestadores.mae"
RUTA_INICIAL=`pwd`
DIR_APROBADOS="$RUTA_INICIAL/preparados"
DIR_RECHAZADOS="$RUTA_INICIAL/rechazados"
RUTA_LOGUEARC="$RUTA_INICIAL/../../funciones/loguearC/"
RUTA_MOVERC="$RUTA_INICIAL/../../funciones/moverC/"

# validarFecha(fecha, fechaDesde, fechaHasta)
#
# Valida que fecha no este en el futuro, y que se encuentre entre fechaDesde y
# fechaHasta. El formato de las fechas es yyyymmdd (ej. 20110823).
# Genera una variable FECHA_VALIDA en 1 si es valida o en 0 si no.
# 
# @fecha: fecha que se quiere validar
# @fechaDesde: menor valor posible para @fecha
# @fechaHasta: mayor valor posible para @fecha
#
function validarFecha {
    # $1: @fecha
    # $2: @fechaDesde
    # $3: @fechaHasta
    FECHA_VALIDA=0
    if [ $1 -le `date +%Y%m%d` ]; then
        if [ $1 -le $3  ]; then
            if [ $1 -ge $2  ]; then
                FECHA_VALIDA=1
            fi
        fi
    fi
}

echo $$ > $PID_FILE # Guardo el pid en un archivo
cd $DIR_ARRIBOS


# Tiene que correr indefinidamente
COUNTER=1
REGEXP_FORMATO_VALIDO='^\./(19|20)[0-9][0-9](0[1-9]|1[0-2])(0[1-9]|[1-2][0-9]|3[01])\.\w{8}$'
MENSAJE_ACEPTADO="Archivo de encuestas aceptado:"
MENSAJE_USUARIO_INVALIDO="Archivo de encuestas rechazado porque el user_id no existe:"
MENSAJE_FECHA_INVALIDA="Archivo de encuestas rechazado porque la fecha no es válida:"
MENSAJE_FORMATO_INVALIDO="Archivo de encuestas rechazado porque el nombre no es del formato <fecha>.<user_id>:"

while [ $COUNTER -eq 1 ]; do
	# Por cada archivo del directorio de arribos
	for file in `find . -type f -maxdepth 1 -print 2>/dev/null`; do
		if echo $file | grep -Eq "$REGEXP_FORMATO_VALIDO" 
		then
		    FECHA_VALIDA=0
		    ENCONTRADO=0
			# El FORMATO es valido (todavia hay que chequear que sea valida la 
			# fecha y el userid
			USERID_ENTRANTE=`echo $file | cut -d . -f 3`
			exec < "../$MAEENC"
			while read linea; do
				if [ $USERID_ENTRANTE = `echo $linea | cut -b 1-8` ]; then
				    ENCONTRADO=1
				    FECHA=`echo $file | cut -b 3-10`
				    FECHA_DESDE=`echo $linea | cut -d , -f 4`
				    FECHA_HASTA=`echo $linea | cut -d , -f 5`
					validarFecha $FECHA $FECHA_DESDE $FECHA_HASTA
				fi
			done
			if [ $ENCONTRADO -eq 1 ]; then
			    if [ $FECHA_VALIDA -eq 1 ]; then
			        $RUTA_MOVERC/moverC.sh -o $file -d $DIR_APROBADOS -c "$0"
				    #$RUTA_LOGUEARC/loguearC.sh -w -t I -m "$MENSAJE_ACEPTADO $file" -p "$0"
			    else
			        $RUTA_MOVERC/moverC.sh -o $file -d $DIR_RECHAZADOS -c "$0"
				    #$RUTA_LOGUEARC/loguearC.sh -w -t I -m "$MENSAJE_FECHA_INVALIDA $file" -p "$0"
			    fi
			else
			    $RUTA_MOVERC/moverC.sh -o $file -d $DIR_RECHAZADOS -c "$0"
			    #$RUTA_LOGUEARC/loguearC.sh -w -t I -m "$MENSAJE_USUARIO_INVALIDO $file" -p "$0"
			fi
		else
		    $RUTA_MOVERC/moverC.sh -o $file -d $DIR_RECHAZADOS -c "$0"
		    #$RUTA_LOGUEARC/loguearC.sh -w -t I -m "$MENSAJE_FORMATO_INVALIDO $file" -p "$0"
		fi
	done
	sleep 30
done
