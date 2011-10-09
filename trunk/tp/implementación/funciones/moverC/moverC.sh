#!/bin/bash            
#
# moverC.sh
# Funcion para movimiento de archivos

RUTA_GRUPO="/home/juani/Desktop/SO"
RUTA_MAE="$RUTA_GRUPO/mae"
RUTA_INICIAL=`pwd`

function esDuplicado
{
	DUPLICADO_ENCONTRADO="NO"
	cd $RUTA_DESTINO
	for ARCHIVO in `find . -type f -maxdepth 1 -print 2>/dev/null`;	do
		if [ $ARCHIVO = "./"$ARCHIVO_ORIGEN ]; then
				DUPLICADO_ENCONTRADO="SI"
		fi
	done
}

function generarRutaDestino 
{
	ARCHIVO_DESTINO=$ARCHIVO_ORIGEN
	cd $RUTA_INICIAL
	cd $RUTA_DESTINO
	NUM_SECUENCIA="1"
	DUP_ENCONTRADO="NO"
	for DIRECTORIO in `find . -type d -maxdepth 1 -print 2>/dev/null`;
	do
		if [ "$DIRECTORIO" = "./dup" ]; then
			DUP_ENCONTRADO="SI"
			cd dup
			for DUPLICADO in `ls -1tr`;
			do
				let "NUM_SECUENCIA=${DUPLICADO##*.}+1"
			done
			ARCHIVO_DESTINO="$ARCHIVO_ORIGEN.$NUM_SECUENCIA"
		fi
	done
	if [ $DUP_ENCONTRADO = "NO" ]; then
		mkdir dup
		ARCHIVO_DESTINO="$ARCHIVO_ORIGEN.1"
	fi
	RUTA_DESTINO="$RUTA_DESTINO/dup"
}

function chequearExistenciaArchivoOrigen
{
	if [ ! -f "$RUTA_ORIGEN" ];	then
			echo "Error: El archivo origen no existe." >&2
			#TODO: loguear error
		  exit -1
	fi
}

function chequearExistenciaRutaDestino
{
	if [ ! -d "$RUTA_DESTINO" ];	then
			echo "Error: La ruta destino no existe." >&2
			#TODO: loguear error
		  exit -2
	fi
}

function mover {
	ARCHIVO_ORIGEN=`basename $RUTA_ORIGEN`
	chequearExistenciaArchivoOrigen
	chequearExistenciaRutaDestino
	esDuplicado
	ARCHIVO_DESTINO="$ARCHIVO_ORIGEN"
	if [ $DUPLICADO_ENCONTRADO = "SI" ]; then
		generarRutaDestino
	fi
	cd $RUTA_INICIAL
	echo "Moviendo el archivo $ARCHIVO_ORIGEN a $RUTA_DESTINO/$ARCHIVO_DESTINO"
	mv "$RUTA_ORIGEN" "$RUTA_DESTINO/$ARCHIVO_DESTINO"
	#TODO: loguear mensaje
}

while getopts o:d:c: opcion
do case "$opcion" in
	o) RUTA_ORIGEN="$OPTARG";;
	d) RUTA_DESTINO="$OPTARG";;
	c) COMANDO="$OPTARG";;
	[?])	echo "Uso: -o archivo_origen -d ruta_destino [-c comando_invocante]"
	esac
done

mover

exit 0
