#!/bin/sh

PROCESO=sumarC

########################################################################################
# Declaración de constantes:
NO_AMBIENTE=3
ERROR=1
OK=0
#
########################################################################################
# Ambiente iniciado?
if [ -z $GRUPO ]; then
    echo "Falta Ambiente"
    exit $NO_AMBIENTE
fi
#
########################################################################################
# Directorios 
PATH_PREPARADOS=$GRUPO/preparados
PATH_LISTOS=$GRUPO/listos
PATH_PROCESADO=$GRUPO/ya
PATH_NOLISTOS=$GRUPO/nolistos
PATH_RECHAZADOS=$GRUPO/rechazados
PATH_ERRONEOS=$PATH_NOLISTOS/encuestas.rech
PATH_SUMA=$PATH_PROCESADO/encuestas.sum
#
########################################################################################
# Variables
archivosProcesados=0
archivosRechazados=0
cantidadPreguntasEncuesta=0
cantidadPreguntasArchivo=0
cantidadEncuestasAceptadas=0
cantidadEncuestasRechazadas=0
actualEncuesta=0
cabeceraValida=1
calculado=0
lineaCabecera=''
#
########################################################################################
# Armado de mascaras. 
INT_N="^[0-9]*$"            # numerico
COD="[A-Za-z0-9]\{3\}"      # Tres caracteres
COD_N="[A-Za-z0-9]*"        # N caracteres
SITIO="[PLESO]"             # Sitio de Relevamiento
MODALIDAD="[ETCP]"          # Modalidad de Encuesta
PERSONA="ID\|II\|RP\|RC"    # Persona Relevada
ORIGEN="ESP\|MKT\|VEN\|LEG" # Campaña de Origen

MASCARA_CABECERA="[Cc],\(.*\),\(.*\),\(.*\),\(.*\),\(.*\),\(.*\),\(.*\),\(ESP\|MKT\|VEN\|LEG\)\(.*\)"
MASCARA_DETALLE="[Dd],\(.*\),\(.*\),[0-9]*\(.*\)"

########################################################################################
# Funciones 
# Recibe en $1 la cadena a evaluar con la regexp de $2
validarFormato(){
    local match=`echo "$1" | grep "$2"`
    if [ -z "$match" ]; then
        return $ERROR
    fi
    return $OK
}

# Recibe $key en $1 y los valores del registro en $2
validar_cabecera(){
    local result
    local -a cabecera=(`echo $2 | sed "s/,[\s ]*,/,@@@,/g" | tr "," "\n"`)

    validarFormato "$1,$2" $MASCARA_CABECERA
    result=$?
    if [ $result -eq $ERROR ]; then
        echo "Faltan campos obligatorios de cabecera,$1,$2" >> $PATH_ERRONEOS
        return $ERROR
    fi

    validarFormato "${cabecera[0]}" $INT_N 
    result=$?
    if [ $result -eq $ERROR ]; then
        echo "Número de encuesta invalido,$1,$2" >> $PATH_ERRONEOS
        return $ERROR
    fi

    # Busco encuesta
    local encuesta=`grep "^${cabecera[1]}," $GRUPO/$DATAMAE/encuestas.mae`
    if [ -z "$encuesta" ]; then
        echo "Encuesta no encontrada,$1,$2" >> $PATH_ERRONEOS
        return $ERROR
    else 
        cantidadPreguntasEncuesta=`echo "$encuesta" | awk -F"," '{print $3}'`
        actualEncuesta=${cabecera[0]}
    fi

    validarFormato "${cabecera[2]}" $INT_N
    result=$?
    if [ $result -eq $ERROR ]; then
        echo "Número de cliente incorrecto,$1,$2" >> $PATH_ERRONEOS
        return $ERROR
    fi

    validarFormato "${cabecera[3]}" $SITIO
    result=$?
    if [ $result -eq $ERROR ]; then
        echo "Sitio de encuesta incorrecto,$1,$2" >> $PATH_ERRONEOS
        return $ERROR
    fi

    validarFormato "${cabecera[4]}" $MODALIDAD
    result=$?
    if [ $result -eq $ERROR ]; then
        echo "Modalidad de encuesta incorrecta,$1,$2" >> $PATH_ERRONEOS
        return $ERROR
    fi

    validarFormato "${cabecera[5]}" $PERSONA
    result=$?
    if [ $result -eq $ERROR ]; then
        echo "Persona relevada incorrecta,$1,$2" >> $PATH_ERRONEOS
        return $ERROR
    fi

    validarFormato "${cabecera[6]}" $INT_N
    result=$?
    if [ $result -eq $ERROR ]; then
        echo "Duración de encuesta incorrecta,$1,$2" >> $PATH_ERRONEOS
        return $ERROR
    fi

    validarFormato "${cabecera[7]}" $ORIGEN
    result=$?
    if [ $result -eq $ERROR ]; then
        echo "Campaña origen de encuesta incorrecta,$1,$2" >> $PATH_ERRONEOS
        return $ERROR
    fi
    
    return $OK
}

# Recibe $key en $1 y los valores del registro en $2
validarDetalle(){
    local result
    local tipo
    local ponderacion
    local -a detalle=(`echo $2 | sed "s/,[\s ]*,/,@@@,/g" | tr "," "\n"`)
    
    if [ $actualEncuesta -ne ${detalle[0]} ]; then
        echo "Número de Encuesta incorrecto,$1,$2" >> $PATH_ERRONEOS
    fi
    
    validarFormato "$1,$2" $MASCARA_DETALLE
    result=$?
    if [ $result -eq $ERROR ]; then
        echo "Faltan campos obligatorios de detalle,$1,$2" >> $PATH_ERRONEOS
        return $ERROR
    fi

    local pregunta=`grep "^${detalle[1]}," $GRUPO/$DATAMAE/preguntas.mae`
    if [ -z "$pregunta" ]; then
        echo "Pregunta no encontrada,$1,$2" >> $PATH_ERRONEOS
        return $ERROR
    else 
        tipo=`echo "$pregunta" | awk -F"," '{print $3}'`
        ponderacion=`echo "$pregunta" | awk -F"," '{print $4}'`
    fi
    
    validarFormato "${detalle[2]}" $INT_N
    result=$?
    if [ $result -eq $ERROR ]; then
        echo "Respuesta incorrecta,$1,$2" >> $PATH_ERRONEOS
        return $ERROR
    fi

    local factor=1
    case $tipo in
        '-')case $ponderacion in 
                [Aa][Ll][Tt][Aa])
                        factor=-3
                            ;;
                [Mm][Ee][Dd][iI][Aa])
                        factor=-2
                            ;;
                [Bb][Aa][Jj][Aa])
                        factor=-1
                            ;;
                *) $GRUPO/$LIBDIR/loguearC.sh -w -t I -m "Ponderacion no encontrada: $ponderacion" -p $PROCESO
            esac
            ;;
        '+')case $ponderacion in 
                [Aa][Ll][Tt][Aa])
                        factor=3
                            ;;
                [Mm][Ee][Dd][iI][Aa])
                        factor=2
                            ;;
                [Bb][Aa][Jj][Aa])
                        factor=1
                            ;;
                *) $GRUPO/$LIBDIR/loguearC.sh -w -t I -m "Ponderación no encontrada: $ponderacion" -p $PROCESO
            esac
            ;;
        *) $GRUPO/$LIBDIR/loguearC.sh -w -t I -m "Tipo de ponderación no encontrada: $tipo" -p $PROCESO
    esac
    let calculado=calculado+${detalle[2]}*$factor

    return $OK
}

procesar(){
    if [ $cabeceraValida -eq $ERROR ] || [ $actualEncuesta -eq 0 ]; then
        return 
    fi
    if [ $cantidadPreguntasEncuesta -ne $cantidadPreguntasArchivo ]; then
        echo "Cantidad de preguntas incorrecto,C,$2" >> $PATH_ERRONEOS
        return    
    fi

    local -a ARCHIVO=(`echo $1 | sed "s/\./ /"`)
    local -a cabecera=(`echo $2 | tr "," "\n"`)

    local preExiste=`cat $PATH_SUMA | grep "\(.*\),\(.*\),$actualEncuesta,\(.*\)" | wc -l`
    if [ $preExiste -ne 0 ]; then
        echo "Numero de encuesta repetido,C,$2" >> $PATH_ERRONEOS
        let cantidadEncuestasRechazadas=cantidadEncuestasRechazadas+1
        return
    fi

    let cantidadEncuestasAceptadas=cantidadEncuestasAceptadas+1
    echo "${ARCHIVO[1]},${ARCHIVO[0]},$actualEncuesta,${cabecera[1]},$calculado,${cabecera[2]},${cabecera[3]},${cabecera[4]},${cabecera[5]}" >> $PATH_SUMA
}

########################################################################################
# INICIA PROCESO 

# Calculo cantidad de Archivos a procesar
files=`ls $PATH_PREPARADOS | wc -l `
$GRUPO/$LIBDIR/loguearC.sh -w -t I -m "Inicio de SumarC: $files archivos" -p $PROCESO

touch $PATH_SUMA

# procesar archivos de $grupo/preparados, solo se entra acá si hay archivos disponibles.
for file in `ls $PATH_PREPARADOS`; do

    $GRUPO/$LIBDIR/loguearC.sh -w -t I -m "Archivo a Procesar: $file" -p $PROCESO

    # chequeo por duplicados.
    existe=`ls "$PATH_LISTOS" | grep "$file" | wc -l`
    if [ $existe -gt 0 ]; then
        $GRUPO/$LIBDIR/moverC.sh -o  "$PATH_PREPARADOS/$file" -d $PATH_RECHAZADOS -c $PROCESO
        $GRUPO/$LIBDIR/loguearC.sh -w -t I -m "Archivo duplicado: $file" -p $PROCESO
        let archivosRechazados=archivosRechazados+1
        continue
    fi

    let archivosProcesados=archivosProcesados+1

    # Leo el archivo fila por fila parseando el primer caracter de la linea, para definir si es Cabecera o Detalle
    while IFS=, read key value
    do
        if [ -z "$value" ] ; then 
            continue
        fi

        case $key in
            C)  # ES CABECERA NUEVA
                procesar $file "$lineaCabecera"

                cabeceraValida=1
                cantidadPreguntasEncuesta=0
                cantidadPreguntasArchivo=0
                
                validar_cabecera $key "$value"
                result=$?
                if [ $result -eq $OK ]; then
                    cabeceraValida=0
                    lineaCabecera="$value"
                else
                    let cantidadEncuestasRechazadas=cantidadEncuestasRechazadas+1
                fi
                ;;

            D)  # ES DETALLE
                if [ $cabeceraValida -eq $OK ] ; then
                    validarDetalle $key "$value"
                    result=$?
                    if [ $result -eq $OK ]; then
                        let cantidadPreguntasArchivo=cantidadPreguntasArchivo+1
                    fi
                else
                    echo ",$key,$value" >> $PATH_ERRONEOS
                fi
                ;;

            *) # ES UN ERROR
                echo "Registro incorrecto,$key,$value" >> $PATH_ERRONEOS
        esac
    done < $PATH_PREPARADOS/$file

    $GRUPO/$LIBDIR/moverC.sh -o  "$PATH_PREPARADOS/$file" -d $PATH_LISTOS -c $PROCESO
done

$GRUPO/$LIBDIR/loguearC.sh -w -t I -m "Fin de SumarC: $archivosProcesados archivos procesados, $archivosRechazados archivos rechazados, $cantidadEncuestasAceptadas encuestas aceptadas, $cantidadEncuestasRechazadas encuestas rechazadas." -p $PROCESO

# FIN PROCESO
########################################################################################
