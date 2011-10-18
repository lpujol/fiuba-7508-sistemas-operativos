#!/bin/sh

PROCESO=sumarC

#Ambiente iniciado?
if [ -z $GRUPO ]; then
    echo "Falta Ambiente"
    exit $NO_AMBIENTE
fi

PATH_PREPARADOS=$GRUPO/preparados
PATH_LISTOS=$GRUPO/listos
PATH_PROCESADO=$GRUPO/ya
PATH_NOLISTOS=$GRUPO/nolistos
PATH_RECHAZADOS=$GRUPO/rechazados
PATH_ERRONEOS=$PATH_NOLISTOS/encuestas.rech
PATH_SUMA=$PATH_PROCESADO/encuestas.sum

########################################################################################
# Declaración de constantes:
NO_AMBIENTE=3
ERROR=1
OK=0
#
########################################################################################
# Variables
archivos_procesados=0
archivos_rechazados=0
cantidad_preguntas_encuesta=0
cantidad_preguntas_archivo=0
cantidad_encuestas_aceptadas=0
cantidad_encuestas_rechazadas=0
actual_encuesta=0
cabecera_valida=1
calculado=0
linea_cabecera=''
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

# Recibe en $1 la cadena a evaluar con la regexp de $2
validar_formato(){
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

    validar_formato "$1,$2" $MASCARA_CABECERA
    result=$?
    if [ $result -eq $ERROR ]; then
        echo "Faltan campos obligatorios de cabecera,$1,$2" >> $PATH_ERRONEOS
        return $ERROR
    fi

    validar_formato "${cabecera[0]}" $INT_N 
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
        cantidad_preguntas_encuesta=`echo "$encuesta" | awk -F"," '{print $3}'`
        actual_encuesta=${cabecera[0]}
    fi

    validar_formato "${cabecera[2]}" $INT_N
    result=$?
    if [ $result -eq $ERROR ]; then
        echo "Número de cliente incorrecto,$1,$2" >> $PATH_ERRONEOS
        return $ERROR
    fi

    validar_formato "${cabecera[3]}" $SITIO
    result=$?
    if [ $result -eq $ERROR ]; then
        echo "Sitio de encuesta incorrecto,$1,$2" >> $PATH_ERRONEOS
        return $ERROR
    fi

    validar_formato "${cabecera[4]}" $MODALIDAD
    result=$?
    if [ $result -eq $ERROR ]; then
        echo "Modalidad de encuesta incorrecta,$1,$2" >> $PATH_ERRONEOS
        return $ERROR
    fi

    validar_formato "${cabecera[5]}" $PERSONA
    result=$?
    if [ $result -eq $ERROR ]; then
        echo "Persona relevada incorrecta,$1,$2" >> $PATH_ERRONEOS
        return $ERROR
    fi

    validar_formato "${cabecera[6]}" $INT_N
    result=$?
    if [ $result -eq $ERROR ]; then
        echo "Duración de encuesta incorrecta,$1,$2" >> $PATH_ERRONEOS
        return $ERROR
    fi

    validar_formato "${cabecera[7]}" $ORIGEN
    result=$?
    if [ $result -eq $ERROR ]; then
        echo "Campaña origen de encuesta incorrecta,$1,$2" >> $PATH_ERRONEOS
        return $ERROR
    fi
    
    return $OK
}

# Recibe $key en $1 y los valores del registro en $2
validar_detalle(){
    local result
    local tipo
    local ponderacion
    local -a detalle=(`echo $2 | sed "s/,[\s ]*,/,@@@,/g" | tr "," "\n"`)
    
    if [ $actual_encuesta -ne ${detalle[0]} ]; then
        echo "Número de Encuesta incorrecto,$1,$2" >> $PATH_ERRONEOS
    fi
    
    validar_formato "$1,$2" $MASCARA_DETALLE
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
    
    validar_formato "${detalle[2]}" $INT_N
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
                *) echo "$ponderacion"
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
                *) echo "$ponderacion"
            esac
            ;;
        *) echo "$tipo"
    esac
    let calculado=calculado+${detalle[2]}*$factor

    return $OK
}

procesar(){
    if [ $cabecera_valida -eq $ERROR ] || [ $actual_encuesta -eq 0 ]; then
        return 
    fi
    if [ $cantidad_preguntas_encuesta -ne $cantidad_preguntas_archivo ]; then
        echo "Cantidad de preguntas incorrecto,C,$2" >> $PATH_ERRONEOS
        return    
    fi

    local -a ARCHIVO=(`echo $1 | sed "s/\./ /"`)
    local -a cabecera=(`echo $2 | tr "," "\n"`)

    let cantidad_encuestas_aceptadas=cantidad_encuestas_aceptadas+1
    echo "${ARCHIVO[1]},${ARCHIVO[0]},$actual_encuesta,${cabecera[1]},$calculado,${cabecera[2]},${cabecera[3]},${cabecera[4]},${cabecera[5]}" >> $PATH_SUMA
}

# Calculo cantidad de Archivos a procesar
files=`ls $PATH_PREPARADOS | wc -l `
$GRUPO/$LIBDIR/loguearC.sh -w -t I -m "Inicio de SumarC: $files archivos" -p $PROCESO

# procesar archivos de $grupo/preparados, solo se entra acá si hay archivos disponibles.
for file in `ls $PATH_PREPARADOS`; do

    $GRUPO/$LIBDIR/loguearC.sh -w -t I -m "Archivo a Procesar: $file" -p $PROCESO

    # chequeo por duplicados.
    existe=`ls "$PATH_LISTOS" | grep "$file" | wc -l`
    if [ $existe -gt 0 ]; then
        $GRUPO/$LIBDIR/moverC.sh -o  "$PATH_PREPARADOS/$file" -d $PATH_RECHAZADOS -c $PROCESO
        $GRUPO/$LIBDIR/loguearC.sh -w -t I -m "Archivo duplicado: $file" -p $PROCESO
        let archivos_rechazados=archivos_rechazados+1
        continue
    fi

    let archivos_procesados=archivos_procesados+1

    # Leo el archivo fila por fila parseando el primer caracter de la linea, para definir si es Cabecera o Detalle
    while IFS=, read key value
    do
        if [ -z "$value" ] ; then 
            continue
        fi

        case $key in
            C)  # ES CABECERA NUEVA
                procesar $file "$linea_cabecera"

                cabecera_valida=1
                cantidad_preguntas_encuesta=0
                cantidad_preguntas_archivo=0
                
                validar_cabecera $key "$value"
                result=$?
                if [ $result -eq $OK ]; then
                    cabecera_valida=0
                    linea_cabecera="$value"
                else
                    let cantidad_encuestas_rechazadas=cantidad_encuestas_rechazadas+1
                fi
                ;;

            D)  # ES DETALLE
                if [ $cabecera_valida -eq $OK ] ; then
                    validar_detalle $key "$value"
                    result=$?
                    if [ $result -eq $OK ]; then
                        let cantidad_preguntas_archivo=cantidad_preguntas_archivo+1
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

$GRUPO/$LIBDIR/loguearC.sh -w -t I -m "Fin de SumarC: $archivos_procesados archivos procesados, $archivos_rechazados archivos rechazados, $cantidad_encuestas_aceptadas encuestas aceptadas, $cantidad_encuestas_rechazadas encuestas rechazadas." -p $PROCESO

