#!/bin/bash
#
# instalarC.sh
# Script para la instalacion del paquete Consultar
#
# Creado por Nicolas Suarez

# Exit Codes
# 0 - Instalacion Completa
# 1 - Ningun componente instalado
# 2 - Instalacion Incompleta

GRUPO=`pwd`
INSTDIR="inst"
CONFDIR="conf"
MAEDIR="mae"
BINDIR="bin"
LIBDIR="lib"
ARRIDIR="arribos"
DATASIZE=100 #MB
LOGDIR="log"
LOGEXT=".log"
LOGSIZE=400 #KB
LOGFILE="$INSTDIR/instalarC.log"
CONFFILE="$CONFDIR/instalarC.conf"
INICIARU=""
INICIARF=""
DETECTARU=""
DETECTARF=""
SUMARU=""
SUMARF=""
LISTARU=""
LISTARF=""

function toLower() {
    echo $1 | tr "[:upper:]" "[:lower:]"
}

function loguear() {
    logDate=`date "+%y-%m-%d_%H-%M-%S"` 
    echo "$logDate,$USER,$1,$2" >> $LOGFILE
}

function echoAndLog() {
    echo -e "$2"
    loguear "$1" "$2"
}

function chequeoInicial() {
    if [ ! -w "$GRUPO" ]; then
        echo "No tiene permisos de escitura en el directorio de instalación"
        echo "Instalación cancelada"
        exit 2
    fi

    if [ ! -d "$INSTDIR" ]; then
        echo "No existe el directorio $INSTDIR"
        echo "Instalación cancelada"
        exit 2
    elif [ ! -w "$INSTDIR" ]; then
        echo "No tiene permisos de escritura sobre el directorio $INSTDIR"
        echo "Instalación cancelada"
        exit 2
    fi
}

#Funcion para crear directorios
#Parametros:
#1 - Permisos 
#2 - Path del directorio a crear
function crearDirectorio() {
    if [ ! -d $2 ]; then
        mkdir -p -m$1 $2 2>/dev/null 
    fi
}

function terminosCondiciones() {
    echo "*****************************************************************"
    echo "*          Sistema Consultar Copyright SisOp (c)2011           *"
    loguear "I" "Sistema Consultar Copyright SisOp (c)2011"
    echo "*****************************************************************"
    loguear "I" "Al instalar Consultar UD. expresa estar en un todo de acuerdo con los términos y condiciones del \"ACUERDO DE LICENCIA DE SOFTWARE\" incluido en este paquete."
    echo "* Al instalar Consultar UD. expresa estar en un todo de acuerdo *"
    echo "* con los términos y condiciones del \"ACUERDO DE LICENCIA DE    *"
    echo "* SOFTWARE\" incluido en este paquete.                           *"
    echo "*****************************************************************"
    echoAndLog "I" "Acepta? (s/n): "

    read respuesta

    loguear "I" "$respuesta"
        
    if [ "$respuesta" = "" ] || [ `toLower $respuesta` != "s" ]; then
        echoAndLog "I" "Instalacion Cancelada"
        exit 1
    fi
}

#Funcion que verifica si la version de perl instalada es 5 o superior
#Return Codes:
#    0 - La version instalada es 5 o superior
#    1 - No esta instalado perl o la version es menor a 5
function verificarPerl() {
    perlVersion=`perl --version | grep -o "v[5-9]\.[0-9]\{1,\}\.[0-9]\{1,\}"`
    if [ $? -ne 0 ]; then
        echoAndLog "SE" "Para instalar Consultar es necesario contar con  Perl 5 o superior instalado. Efectúe su instalación e inténtelo nuevamente. Proceso de Instalación Cancelado."
        exit 1
    else
        echoAndLog "I" "Version de Perl instalada: $perlVersion"
	echo ""
    fi
}

function mensajesInformativos() {
    echoAndLog "I" "Todos los directorios del sistema serán subdirectorios de $GRUPO"
    echoAndLog "I" "Todos los componentes de la instalación se obtendrán del repositorio: $GRUPO/$INSTDIR"
    listado=`ls $GRUPO/$INSTDIR`
    echoAndLog "I" "Contenido del repositorio: $listado"
    echoAndLog "I" "El log de la instalación se almacenara en $GRUPO/$INSTDIR"
    echo ""
    echoAndLog "I" "Al finalizar la instalación, si la misma fue exitosa se dejara un archivo de configuración en $GRUPO/$CONFDIR"
    echo ""
}

function definirDirBinarios() {
    isOk=0
    while [ "$isOk" -eq 0 ]; do
        echoAndLog "I" "Ingrese el nombre del directorio de ejecutables ($BINDIR):"
        read dirBin
        if [ ! -z "$dirBin" ]; then
            value=`echo $dirBin | grep "^\(\w\|_\)\+\(/\(\w\|_\)\+\)*$"`
            if [ $? -eq 0 ]; then
                BINDIR=$dirBin
                isOk=1
            else
                echoAndLog "E" "$dirBin no es un nombre de directorio valido."
		echo ""
            fi
        else
            isOk=1
        fi 
    done
    loguear "I" "Directorio de ejecutables: $BINDIR"
}

function definirDirArribos() {
    isOk=0
    while [ "$isOk" -eq 0 ]; do
        echoAndLog "I" "Ingrese el nombre del directorio que permite el arribo de archivos externos ($ARRIDIR):"
        read dirArribos
        if [ ! -z "$dirArribos" ]; then
            value=`echo $dirArribos | grep "^\(\w\|_\)\+\(/\(\w\|_\)\+\)*$"`
            if [ $? -eq 0 ]; then
                ARRIDIR=$dirArribos
                isOk=1
            else
                echoAndLog "E" "$dirArribos no es un nombre de directorio valido."
		echo ""
            fi
        else
            isOk=1
        fi 
    done
    loguear "I" "Directorio de arribo de archivos externos: $ARRIDIR"

    #Espacio disponible para ARRIDIR
    freeSize=0
    while [ $freeSize -lt $DATASIZE ]; do
        isOk=0
        while [ "$isOk" -eq 0 ]; do    
            echoAndLog "I" "Ingrese el espacio minimo requerido para datos externos en MB ($DATASIZE MB):"
            read dataSize
            if [ ! -z $dataSize ]; then
                value=`echo $dataSize | grep "^[0-9]\+$"`
                if [ $? -eq 0 ]; then
                    DATASIZE=$dataSize
                    isOk=1
                else
                    echoAndLog "E" "$dataSize no es un valor válido. Ingrese un valor numérico"
		    echo ""
                fi
            else
                isOk=1
            fi
        done

        #Chequeo espacio disponible en disco
        freeSize=`df $GRUPO | tail -n 1 | sed 's/\s\+/ /g' | cut -d ' ' -f 4`
        let freeSize=$freeSize/1024
        if [ $freeSize -lt $DATASIZE ]; then
            echoAndLog "E" "Insuficiente espacio en disco. Espacio disponible: $freeSize MB. Espacio requerido $DATASIZE MB"
	    echo ""
        fi
    done
    loguear "I" "Espacio para datos externos: $DATASIZE"
}

function definirDirLog() {
    isOk=0
    while [ "$isOk" -eq 0 ]; do
        echoAndLog "I" "Ingrese el nombre del directorio de log ($LOGDIR):"
        read dirLog
        if [ ! -z "$dirLog" ]; then
            value=`echo $dirLog | grep "^\(\w\|_\)\+\(/\(\w\|_\)\+\)*$"`
            if [ $? -eq 0 ]; then
                LOGDIR=$dirLog
                isOk=1
            else
                echoAndLog "E" "$dirLog no es un nombre de directorio valido."
		echo ""
            fi
        else
            isOk=1
        fi 
    done
    loguear "I" "Directorio de log: $LOGDIR"


    #Extension para los archivos de log
    isOk=0
    while [ "$isOk" -eq 0 ]; do
    echoAndLog "I" "Ingrese la extension para los archivos de log ($LOGEXT):"
    read logExt
    if [ ! -z "$logExt" ]; then
        value=`echo $logExt | grep "^\.\w\{1,\}$"`
        if [ $? -eq 0 ]; then
            LOGEXT=$logExt
            isOk=1
        else
            echoAndLog "E" "$logExt no es un nombre de extensión valido."
	    echo ""
        fi
    else
        isOk=1
    fi 
    done
    loguear "I" "Extension archivos de log: $LOGDIR"


    #Tamaño maximo para archivos de log
    isOk=0
    while [ "$isOk" -eq 0 ]; do    
    echoAndLog "I" "Ingrese el tamaño máximo para los archivos <$LOGEXT> en KB ($LOGSIZE):"
    read logSize
    if [ ! -z $logSize ]; then
        value=`echo $logSize | grep "^[0-9]\+$"`
        if [ $? -eq 0 ]; then
            LOGSIZE=$logSize
            isOk=1
        else
            echoAndLog "E" "$logSize no es un valor válido. Ingrese un valor numérico"
	    echo ""
        fi
    else
        isOk=1
    fi
    done
    loguear "I" "Tamaño máximo para archivos de log: $LOGSIZE"
}

function mostrarParametros() {
    echo "********************************************************"
    echo -n "* "
    echoAndLog "I" "Parámetros de Instalación del paquete  Consultar"
    echo "********************************************************"
    echoAndLog "I" "Directorio de trabajo: $GRUPO"
    echoAndLog "I" "Directorio de instalación: $INSTDIR"
    echoAndLog "I" "Directorio de configuración: $CONFDIR"
    echoAndLog "I" "Directorio de datos maestros: $MAEDIR"
    echoAndLog "I" "Directorio de ejecutables: $BINDIR"
    echoAndLog "I" "Librería de funciones: lib"
    echoAndLog "I" "Directorio de arribos: $ARRIDIR"
    echoAndLog "I" "Espacio mínimo reservado en $ARRIDIR: $DATASIZE MB"
    echoAndLog "I" "Directorio para los archivos de Log: $LOGDIR"
    echoAndLog "I" "Extensión para los archivos de Log: $LOGEXT"
    echoAndLog "I" "Tamaño máximo para cada archivo de Log: $LOGSIZE Kb"
    echoAndLog "I" "Log de la instalación: $INSTDIR"
    echo ""
}

function confirmarParametros() {
    echoAndLog "I" "Si los datos ingresados son correctos de ENTER para continuar, si desea modificar algún parámetro oprima cualquier tecla para reiniciar"
    echo ""
    read -s -n1 respuesta

    if [ "$respuesta" = "" ]; then
        return 0
    else
        return 1
    fi
}

function confirmarInstalacion() {
    echoAndLog "I" "Iniciando Instalación… Está UD. seguro? (Si/No):"
    read respuesta
    if [ "$respuesta" = "" ] || [ `toLower $respuesta` != "si" ]; then
        echoAndLog "I" "Instalacion Cancelada"
        exit 1
    fi
}

function crearDirectorios() {
    echo "Creando estructuras de directorio..." 
    echo ""
    crearDirectorio 755 "$GRUPO/$CONFDIR"
    crearDirectorio 755 "$GRUPO/$MAEDIR"
    crearDirectorio 755 "$GRUPO/$BINDIR"
    crearDirectorio 755 "$GRUPO/$ARRIDIR"
    crearDirectorio 755 "$GRUPO/$LOGDIR"
    crearDirectorio 755 "$GRUPO/$LIBDIR"
    crearDirectorio 755 "$GRUPO/rechazados"
    crearDirectorio 755 "$GRUPO/preparados"
    crearDirectorio 755 "$GRUPO/listos"
    crearDirectorio 755 "$GRUPO/nolistos"
    crearDirectorio 755 "$GRUPO/ya"
}

#Funcion para mover archivos
#Parametros:
#    1 - Archivo a mover
#    2 - Path destino del archivo
#    3 - Permisos del archivo
function moverArchivo() {
    if [ -f "$2/${1##*/}" ]; then
	return 2
    fi

    if [ ! -f $1 ]; then 
        loguear "E" "200:Archivo inexistente: ${1##*/}" 
        return 1
    elif [ ! -d $2 ]; then
        loguear "E" "200:Directorio inexistente: $2"
        return 1
    else
        mv $1 $2 2>/dev/null
        if [ $? -ne 0 ]; then
            loguear "E" "210:No se pudo mover el archivo: ${1##*/}"
            return 1
        else
            chmod "$3" "$2/${1##*/}" 2>/dev/null
        fi
    fi
}

function moverArchivos() {
    echo "Moviendo archivos..."
    echo ""
    moverArchivo "$GRUPO/$INSTDIR/encuestas.mae" "$GRUPO/$MAEDIR" "444"
    moverArchivo "$GRUPO/$INSTDIR/preguntas.mae" "$GRUPO/$MAEDIR" "444"
    moverArchivo "$GRUPO/$INSTDIR/encuestadores.mae" "$GRUPO/$MAEDIR" "444"
    moverArchivo "$GRUPO/$INSTDIR/errores.mae" "$GRUPO/$MAEDIR" "444"
    moverArchivo "$GRUPO/$INSTDIR/moverC.sh" "$GRUPO/$LIBDIR" "775"
    moverArchivo "$GRUPO/$INSTDIR/loguearC.sh" "$GRUPO/$LIBDIR" "775"
    moverArchivo "$GRUPO/$INSTDIR/StartD.sh" "$GRUPO/$LIBDIR" "775"
    moverArchivo "$GRUPO/$INSTDIR/StopD.sh" "$GRUPO/$LIBDIR" "775"
    moverArchivo "$GRUPO/$INSTDIR/mirarC.sh" "$GRUPO/$LIBDIR" "775"

    moverArchivo "$GRUPO/$INSTDIR/iniciarC.sh" "$GRUPO/$BINDIR" "775"
    if [ $? -eq 0 ]; then
        INICIARU=$USER
        INICIARF=`date +"%F %T"`
    fi

    moverArchivo "$GRUPO/$INSTDIR/listarC.pl" "$GRUPO/$BINDIR" "775"
    if [ $? -eq 0 ]; then
        LISTARU=$USER
        LISTARF=`date +"%F %T"`
    fi

    moverArchivo "$GRUPO/$INSTDIR/sumarC.sh" "$GRUPO/$BINDIR" "775"
    if [ $? -eq 0 ]; then
        SUMARU=$USER
        SUMARF=`date +"%F %T"`
    fi

    moverArchivo "$GRUPO/$INSTDIR/detectarC.sh" "$GRUPO/$BINDIR" "775"
    if [ $? -eq 0 ]; then
        DETECTARU=$USER
        DETECTARF=`date +"%F %T"`
    fi    
}

function leerConfiguracion() {
    if [ -f $CONFFILE ]; then
        GRUPO=`grep "CURRDIR" $CONFFILE | cut -s -f2 -d'='`    
        CONFDIR=`grep "CONFDIR" $CONFFILE | cut -s -f2 -d'='`    
        DATAMAE=`grep "DATAMAE" $CONFFILE | cut -s -f2 -d'='`    
        LIBDIR=`grep "LIBDIR" $CONFFILE | cut -s -f2 -d'='`    
        BINDIR=`grep "BINDIR" $CONFFILE | cut -s -f2 -d'='`    
        ARRIDIR=`grep "ARRIDIR" $CONFFILE | cut -s -f2 -d'='`    
        DATASIZE=`grep "DATASIZE" $CONFFILE | cut -s -f2 -d'='`    
        LOGSIZE=`grep "MAXLOGSIZE" $CONFFILE | cut -s -f2 -d'='`    
        LOGDIR=`grep "LOGDIR" $CONFFILE | cut -s -f2 -d'='`    
        LOGEXT=`grep "LOGEXT" $CONFFILE | cut -s -f2 -d'='`    
        INICIARU=`grep "INICIARU" $CONFFILE | cut -s -f2 -d'='`    
        INICIARF=`grep "INICIARF" $CONFFILE | cut -s -f2 -d'='`    
        DETECTARU=`grep "DETECTARU" $CONFFILE | cut -s -f2 -d'='`    
        DETECTARF=`grep "DETECTARF" $CONFFILE | cut -s -f2 -d'='`    
        SUMARU=`grep "SUMARU" $CONFFILE | cut -s -f2 -d'='`    
        SUMARF=`grep "SUMARF" $CONFFILE | cut -s -f2 -d'='`    
        LISTARU=`grep "LISTARU" $CONFFILE | cut -s -f2 -d'='`    
        LISTARF=`grep "LISTARF" $CONFFILE | cut -s -f2 -d'='`    
    fi
}

function guardarConfiguracion() {
    echo "CURRDIR=$GRUPO" > $CONFFILE    
    echo "CONFDIR=$CONFDIR" >> $CONFFILE
    echo "DATAMAE=$MAEDIR" >> $CONFFILE
    echo "LIBDIR=$LIBDIR" >> $CONFFILE
    echo "BINDIR=$BINDIR" >> $CONFFILE
    echo "ARRIDIR=$ARRIDIR" >> $CONFFILE
    echo "DATASIZE=$DATASIZE" >> $CONFFILE
    echo "LOGDIR=$LOGDIR" >> $CONFFILE
    echo "LOGEXT=$LOGEXT" >> $CONFFILE
    echo "MAXLOGSIZE=$LOGSIZE" >> $CONFFILE
    echo "INICIARU=$INICIARU" >> $CONFFILE
    echo "INICIARF=$INICIARF" >> $CONFFILE
    echo "DETECTARU=$DETECTARU" >> $CONFFILE
    echo "DETECTARF=$DETECTARF" >> $CONFFILE
    echo "SUMARU=$SUMARU" >> $CONFFILE
    echo "SUMARF=$SUMARF" >> $CONFFILE
    echo "LISTARU=$LISTARU" >> $CONFFILE
    echo "LISTARF=$LISTARF" >> $CONFFILE
}


#Funcion que detecta si estan todos los componentes instalados
#Return Codes:
#     0: Instalacion completa
#     1: Ningun componente instalado
#     2: Instalacion incompleta  
function detectarInstalacion {
    cantInst=0
    cantNoInst=0
    unset instalados
    unset noinstalados
    
    archivosAVerificar=(    "$GRUPO/$BINDIR/iniciarC.sh"
                "$GRUPO/$BINDIR/detectarC.sh"
                "$GRUPO/$BINDIR/sumarC.sh"
                "$GRUPO/$BINDIR/listarC.pl"
                "$GRUPO/$MAEDIR/encuestas.mae"
                "$GRUPO/$MAEDIR/preguntas.mae"
                "$GRUPO/$MAEDIR/encuestadores.mae"
                "$GRUPO/$MAEDIR/errores.mae"
                "$GRUPO/$LIBDIR/moverC.sh"
                "$GRUPO/$LIBDIR/loguearC.sh"
                "$GRUPO/$LIBDIR/StartD.sh"
                "$GRUPO/$LIBDIR/StopD.sh"
                "$GRUPO/$LIBDIR/mirarC.sh"
               )

    for archivo in ${archivosAVerificar[*]}
    do
        if [ -f "$archivo" ]; then
            owner=`ls -l $archivo | awk '{print $3 " " $6 " " $7}'`
            instalados[$cantInst]="${archivo##*/} $owner"
            let cantInst=$cantInst+1
        else
            noinstalados[$cantNoInst]="${archivo##*/}"
            let cantNoInst=$cantNoInst+1
        fi
    done
    
    if [  $cantInst -gt 0 ] && [ -f "$CONFFILE" ]; then
        if [ $cantNoInst -gt 0 ]; then 
            status=2 #Instalacion incompleta
        else
            status=0 #Instalacion completa
        fi                
    else
        status=1 #No se instalo ningun componente
    fi

    return $status
}

function mostrarComponentesInstalados() {
    detectarInstalacion

    echo "********************************************************" 
    echo "*   Sistema Consultar Copyright SisOp (c)2011          *"
    loguear "I" "Sistema Consultar Copyright SisOp (c)2011"
    echo "********************************************************"
    
    if [ $cantInst -gt 0 ]; then
	echo -n "* "
        echoAndLog "I" "Se encuentran instalados los siguientes componentes:"
	echo ""
        arr=("${instalados[@]}")
        for index in ${!arr[*]}
        do
	    echo -n "  "
            echoAndLog "I" "${arr[$index]}"
        done
    fi

    if [ $cantNoInst -gt 0 ]; then 
	echo -e -n "\n* " 
        echoAndLog "I" "Falta instalar los siguientes componentes:"    
	echo ""
        for item in ${noinstalados[*]}
        do
	    echo -n "  "
            echoAndLog "I" "$item"
        done
        echo ""
    fi
}

#-----------------------------------------------------------------------------------------------#
#----------------------------------------------MAIN---------------------------------------------#
#-----------------------------------------------------------------------------------------------#

loguear "I" "Inicio de Ejecucion"
clear
chequeoInicial
leerConfiguracion
detectarInstalacion
case "$?" in 
    0 )     #Instalacion completa
        mostrarComponentesInstalados
	echo -n "* "
        echoAndLog "I" "Proceso de Instalacion Cancelado"
        exit 0;;

    1 )     #No hay instalacion previa
        terminosCondiciones
        verificarPerl
        mensajesInformativos
        modifica=1
        while [ $modifica -ne 0 ]; do
            definirDirBinarios
            definirDirArribos
            definirDirLog
            clear
            mostrarParametros
            confirmarParametros
            modifica=$?
        done;;

    2 ) #Instalacion previa incompleta
        mostrarComponentesInstalados
        mostrarParametros;;
esac

confirmarInstalacion
crearDirectorios
moverArchivos
guardarConfiguracion
mostrarComponentesInstalados
echo "********************************************************" 
echo -n "* "
echoAndLog "I" "Fin del proceso de instalacion Copyright SisOp (c)2011"
echo "********************************************************" 
exit $?
