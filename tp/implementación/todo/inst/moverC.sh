#!/bin/bash            
#
# Nombre: moverC
# Autor: Juan Ignacio Calcagno
#
# Funcion para movimiento de archivos
#

RUTA_INICIAL=`pwd`
COMANDO="Comando no especificado"

# esDuplicado()
#
# Devuelve si un archivo esta duplicado en la variable DUPLICADO_ENCONTRADO
# 
function esDuplicado
{
    DUPLICADO_ENCONTRADO="NO"
    cd $RUTA_DESTINO
    for ARCHIVO in `find . -type f -maxdepth 1 -print 2>/dev/null`;    do
        if [ $ARCHIVO = "./"$ARCHIVO_ORIGEN ]; then
                DUPLICADO_ENCONTRADO="SI"
        fi
    done
}

# generarRutaDestino
#
# Genera la ruta destino final del archivo, fijandose si esta duplicado o no.
#
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

# chequearExistenciaArchivoOrigen()
#
# Se fija si el archivo de origen existe.
#
function chequearExistenciaArchivoOrigen
{
    if [ ! -f "$RUTA_ORIGEN" ];    then
        $GRUPO/$LIBDIR/loguearC.sh -w -t E200 -m $ARCHIVO_ORIGEN -p "moverC"
        exit -1
    fi
}

# chequear existenciaRutaDestino()
#
# Se fija si la ruta de destino es valida.
#
function chequearExistenciaRutaDestino
{
    if [ ! -d "$RUTA_DESTINO" ];    then
        $GRUPO/$LIBDIR/loguearC.sh -w -t E202 -m $RUTA_DESTINO -p "moverC"
        exit -2
    fi
}

# mover()
#
# Funcion principal del script.
#
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

    mv "$RUTA_ORIGEN" "$RUTA_DESTINO/$ARCHIVO_DESTINO"
    $GRUPO/$LIBDIR/loguearC.sh -w -t I -m "Archivo $ARCHIVO_ORIGEN movido a $RUTA_DESTINO/$ARCHIVO_DESTINO" -p $COMANDO
}

while getopts o:d:c: opcion
do case "$opcion" in
    o) RUTA_ORIGEN="$OPTARG";;
    d) RUTA_DESTINO="$OPTARG";;
    c) COMANDO="$OPTARG";;
    [?])    echo "Uso: -o archivo_origen -d ruta_destino [-c comando_invocante]"
    esac
done

#Llamo a la funcion principal
mover

exit 0
