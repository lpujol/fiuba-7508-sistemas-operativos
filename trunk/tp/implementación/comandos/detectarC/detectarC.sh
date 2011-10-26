#!/bin/bash
#
# Nombre: detectarC
# Autor: Juan Ignacio Calcagno
#
# Este script detecta archivos en la carpeta de arribos, valida sus nombres,
# en base a lo que o los mueve a la carpeta de preparados o los mueve a la
# carpeta de rechazados.
# Una vez procesado el directorio de arribos, si en el directorio de aprobados
# hay archivos invoca el comando sumarC
#

# Variables
MAEENC="$DATAMAE/encuestadores.mae" # Archivo maestro de encuestadores
DIR_APROBADOS="$GRUPO/preparados" # Directorio de archivos aprobados
DIR_RECHAZADOS="$GRUPO/rechazados" # Directorio de archivos rechazados
RUTA_LOGUEARC="$LIBDIR/" # Ruta de la funcion loguearC
RUTA_MOVERC="$LIBDIR/" # Ruta de la funcion moverC

# Ambiente iniciado?
if [ -z $GRUPO ]; then
    echo "Falta Ambiente"
    exit 3
fi

# validarRangoFecha(fecha, fechaDesde, fechaHasta)
#
# Valida que fecha no este en el futuro, y que se encuentre entre fechaDesde y
# fechaHasta. El formato de las fechas es yyyymmdd (ej. 20110823).
# Genera una variable FECHA_VALIDA en 1 si es valida o en 0 si no.
# 
# @fecha: fecha que se quiere validar
# @fechaDesde: menor valor posible para @fecha
# @fechaHasta: mayor valor posible para @fecha
#
function validarRangoFecha {
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

# validarFecha(fecha)
#
# Toma un string que PARECE una fech en formato yyyymmdd, y valida que los
# últimos días de los meses sean correctos. (ej. descartar 31 de Noviembre, 30
# de Febrero, etc)
#
function validarFecha {
    # $1: @fecha
    YYYY=`echo $1 | cut -b 1-4`
    MM=`echo $1 | cut -b 5-6`
    DD=`echo $1 | cut -b 7-8`
    case "$MM" in
        "01" | "03" | "05" | "07" | "08" | "10" | "12" )
        # Estamos validando un mes de 31 dias
        if [ $DD -gt 31 ]; then
            return 0
        fi
        ;;
        "04" | "06" | "09" | "11" )
        # Estamos validando un mes de 30 dias
        if [ $DD -gt 30 ]; then
            return 0
        fi
        ;;
        "02" )
        # Estamos validando febrero, que puede tener 28 o 29 dias
        if [ $[$YYYY % 400] -eq "0" ]; then
            # Si el año es divisible por 400, entonces es bisiesto.
            if [ $DD -gt 29 ]; then
                return 0
            fi
        elif [ $[$YYYY % 4] -eq 0 ]; then
            if [ $[$YYYY % 100] -ne 0 ]; then
                # Si el año es divisible por 4, pero no por 100, es bisiesto.
                if [ $DD -gt 29 ]; then
                    return 0
                fi
            else
                if [ $DD -gt 28 ]; then
                    return 0
                fi
            fi
        else
            # No es un año bisiesto
            if [ $DD -gt 28 ]; then
                return 0
            fi
        fi
        ;;
    esac
    return 1
}

# chequearProcesoSumarC()
#
# Chequea si el script sumarC esta corriendo o no. Devuelve el pid del
# proceso en ese caso, o 0 si no.
#
function chequearProcesoSumarC {
    PID_SUMARC=`ps | grep "sumarC.sh" | head -1 | awk '{print $1 }'`	
	if [ "$PID_SUMARC" != "" ]; then
	    return $PID_SUMARC
	fi 
	return 0
}

cd $GRUPO/$ARRIDIR

COUNTER=1 # Este es el contador de veces que se debe ejecutar el loop
	  # principal. Como debe correr indefinidamente, no va a ser
	  # incrementado.
REGEXP_FORMATO_VALIDO='^(19|20)[0-9][0-9](0[1-9]|1[0-2])(0[1-9]|[1-2][0-9]|3[01])\.\w{8}$' 
MENSAJE_ACEPTADO="Archivo de encuestas aceptado:"
MENSAJE_USUARIO_INVALIDO="Archivo de encuestas rechazado porque el user_id no existe:"
MENSAJE_FECHA_INVALIDA="Archivo de encuestas rechazado porque la fecha no es válida:"
MENSAJE_FORMATO_INVALIDO="Archivo de encuestas rechazado porque el nombre no es del formato <fecha>.<user_id>:"
MENSAJE_ARCHIVO_INVALIDO="Archivo de encuestas rechazado porque es un directorio:"

while [ $COUNTER -eq 1 ]; do
	# Por cada archivo del directorio de arribos
	SAVEIFS=$IFS
	IFS=$(echo -en "\n\b")
	for file in `ls -1tr .`; do
		if [ -d "$file" ]; then
			$GRUPO/$LIBDIR/moverC.sh -o "$file" -d $DIR_RECHAZADOS -c "detectarC"
			$GRUPO/$LIBDIR/loguearC.sh -w -t I -m "$MENSAJE_ARCHIVO_INVALIDO $file" -p "detectarC"
		elif echo "$file" | grep -Eq "$REGEXP_FORMATO_VALIDO" 
		then
		    FECHA_VALIDA=0
		    ENCONTRADO=0
			# El FORMATO es valido (todavia hay que chequear que sea valida la 
			# fecha y el userid
			USERID_ENTRANTE=`echo $file | cut -d . -f 2`
			exec < "$GRUPO/$DATAMAE/encuestadores.mae"
			while read linea; do
				if [ $USERID_ENTRANTE = `echo $linea | cut -b 1-8` ]; then
				    ENCONTRADO=1
				    FECHA=`echo $file | cut -b 1-8`
				    FECHA_DESDE=`echo $linea | cut -d , -f 4`
				    FECHA_HASTA=`echo $linea | cut -d , -f 5`
				    validarFecha $FECHA
				    if [ $? -eq 1 ]; then
    					validarRangoFecha $FECHA $FECHA_DESDE $FECHA_HASTA
    			    fi
				fi
			done
			if [ $ENCONTRADO -eq 1 ]; then
			    if [ $FECHA_VALIDA -eq 1 ]; then
			        $GRUPO/$LIBDIR/moverC.sh -o $file -d $DIR_APROBADOS -c "detectarC"
				    $GRUPO/$LIBDIR/loguearC.sh -w -t I -m "$MENSAJE_ACEPTADO $file" -p "detectarC"
			    else
			        $GRUPO/$LIBDIR/moverC.sh -o $file -d $DIR_RECHAZADOS -c "detectarC"
				    $GRUPO/$LIBDIR/loguearC.sh -w -t I -m "$MENSAJE_FECHA_INVALIDA $file" -p "detectarC"
			    fi
			else
			    $GRUPO/$LIBDIR/moverC.sh -o $file -d $DIR_RECHAZADOS -c "detectarC"
			    $GRUPO/$LIBDIR/loguearC.sh -w -t I -m "$MENSAJE_USUARIO_INVALIDO $file" -p "detectarC"
			fi
		else
		    $GRUPO/$LIBDIR/moverC.sh -o "$file" -d $DIR_RECHAZADOS -c "detectarC"
		    $GRUPO/$LIBDIR/loguearC.sh -w -t I -m "$MENSAJE_FORMATO_INVALIDO $file" -p "detectarC"
		fi
	done
	IFS=$SAVEIFS
	if [ "$(ls -1tr $DIR_APROBADOS)" ]; then
	    chequearProcesoSumarC
	    if [ $? -ne 0 ]; then
		    echo "sumarC ya estaba en ejecución con PID $PID_SUMARC"
		    $GRUPO/$LIBDIR/loguearC.sh -w -t I -m "Se intentó correr sumarC, pero ya estaba en ejecucion" -p "detectarC"
    	    else
    	       	cd $GRUPO/$BINDIR/ 
		. sumarC.sh > /dev/null 2>&1 &
    	        chequearProcesoSumarC
   		if [ $? -ne 0 ]; then
			echo "sumarC corriendo con PID $PID_SUMARC"
			$GRUPO/$LIBDIR/loguearC.sh -w -t I -m "sumarC corriendo con PID $PID_SUMARC" -p "detectarC"
		fi
		cd $GRUPO/$ARRIDIR
	    fi
	fi
	sleep 5
done
