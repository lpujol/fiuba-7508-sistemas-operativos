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
	echo "$logDate,$USER,instalarC,$1,$2" >> $LOGFILE
}

function echoAndLog() {
	echo -e "$2"
	loguear "$1" "$2"
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
	mensaje="*****************************************************************\n"
	mensaje+="*           Sistema Consultar Copyright SisOp (c)2011           *\n"
	mensaje+="*****************************************************************\n"
	mensaje+="* Al instalar Consultar UD. expresa estar en un todo de acuerdo *\n"
	mensaje+="* con los términos y condiciones del \"ACUERDO DE LICENCIA DE    *\n"
	mensaje+="* SOFTWARE\" incluido en este paquete.                           *\n"
	mensaje+="*****************************************************************\n"
	mensaje+="Acepta? (s/n): "
	echo -e -n "$mensaje"

	read respuesta

	loguear "I" "$mensaje $respuesta"
		
	if [ "$respuesta" = "" ] || [ `toLower $respuesta` != "s" ]; then
		echoAndLog "I" "Instalacion Cancelada\n"
		exit 1
	fi
}

#Funcion que verifica si la version de perl instalada es 5 o superior
#Return Codes:
#	0 - La version instalada es 5 o superior
#	1 - No esta instalado perl o la version es menor a 5
function verificarPerl() {
	perlVersion=`perl --version | grep -o "v[5-9]\.[0-9]\{1,\}\.[0-9]\{1,\}"`
	if [ $? -ne 0 ]; then
		mensaje="Para instalar Consultar es necesario contar con  Perl 5 o superior instalado.\n"
		mensaje+="Efectúe su instalación e inténtelo nuevamente. Proceso de Instalación Cancelado."
		echoAndLog "SE" "$mensaje"
		exit 1
	else
		echoAndLog "I" "Version de Perl instalada: $perlVersion\n"
	fi
}

function mensajesInformativos() {
	echoAndLog "I" "Todos los directorios del sistema serán subdirectorios de $GRUPO"
	echoAndLog "I" "Todos los componentes de la instalación se obtendrán del repositorio: $GRUPO/$INSTDIR"
	listado=`ls $GRUPO/$INSTDIR`
	echoAndLog "I" "$listado\n"
	echoAndLog "I" "El log de la instalación se almacenara en $GRUPO/$INSTDIR"
	echoAndLog "I" "Al finalizar la instalación, si la misma fue exitosa se dejara un archivo de configuración en $GRUPO/$CONFDIR"
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
				echoAndLog "E" "$dirBin no es un nombre de directorio valido.\n"
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
				echoAndLog "E" "$dirArribos no es un nombre de directorio valido.\n"
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
					echoAndLog "E" "$dataSize no es un valor válido. Ingrese un valor numérico\n"
				fi
			else
				isOk=1
			fi
		done

		#Chequeo espacio disponible en disco
		freeSize=`df $GRUPO | tail -n 1 | sed 's/\s\+/ /g' | cut -d ' ' -f 4`
		if [ $freeSize -lt $DATASIZE ]; then
			echoAndLog "E" "Insuficiente espacio en disco. Espacio disponible: $freeSize MB. Espacio requerido $DATASIZE MB\n"
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
				echoAndLog "E" "$dirLog no es un nombre de directorio valido.\n"
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
			echoAndLog "E" "$logExt no es un nombre de extensión valido.\n"
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
			echoAndLog "E" "$logSize no es un valor válido. Ingrese un valor numérico\n"
		fi
	else
		isOk=1
	fi
	done
	loguear "I" "Tamaño máximo para archivos de log: $LOGSIZE"
}

function mostrarParametros() {
	mensaje="********************************************************\n"
	mensaje+="* Parámetros de Instalación del paquete  Consultar     *\n"
	mensaje+="********************************************************\n"
	mensaje+="Directorio de trabajo: $GRUPO\n"
	mensaje+="Directorio de instalación: $INSTDIR\n"
	mensaje+="Directorio de configuración: $CONFDIR\n"
	mensaje+="Directorio de datos maestros: $MAEDIR\n"
	mensaje+="Directorio de ejecutables: $BINDIR\n"
	mensaje+="Librería de funciones: lib\n"
	mensaje+="Directorio de arribos: $ARRIDIR\n"
	mensaje+="Espacio mínimo reservado en $ARRIDIR: $DATASIZE MB\n"
	mensaje+="Directorio para los archivos de Log: $LOGDIR\n"
	mensaje+="Extensión para los archivos de Log: $LOGEXT\n"
	mensaje+="Tamaño máximo para cada archivo de Log: $LOGSIZE Kb\n"
	mensaje+="Log de la instalación: $INSTDIR\n\n"
	echoAndLog "I" "$mensaje"
}

function confirmarParametros() {
	mensaje="Si los datos ingresados son correctos de ENTER para continuar, si\n"
	mensaje+="desea modificar algún parámetro oprima cualquier tecla para reiniciar\n"
	echoAndLog "I" "$mensaje"	
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
		echoAndLog "I" "Instalacion Cancelada\n"
		exit 1
	fi
}

function crearDirectorios() {
	echo "Creando estructuras de directorio..." 
	crearDirectorio 744 "$GRUPO/$CONFDIR"
	crearDirectorio 744 "$GRUPO/$MAEDIR"
	crearDirectorio 755 "$GRUPO/$BINDIR"
	crearDirectorio 777 "$GRUPO/$ARRIDIR"
	crearDirectorio 777 "$GRUPO/$LOGDIR"
	crearDirectorio 777 "$GRUPO/rechazados"
	crearDirectorio 777 "$GRUPO/preparados"
	crearDirectorio 777 "$GRUPO/listos"
	crearDirectorio 777 "$GRUPO/nolistos"
	crearDirectorio 777 "$GRUPO/ya"
}

#Funcion para mover archivos
#Parametros:
#	1 - Archivo a mover
#	2 - Path destino del archivo
function moverArchivo() {
	if [ ! -f $1 ]; then 
		loguear "E" "No se puede mover el archivo ${1##*/}. Archivo inexistente" 
		return 1
	elif [ ! -d $2 ]; then
		loguear "E" "No se puede mover el archivo ${1##*/}. El directorio $2 no existe"
		return 1
	else
		mv -u $1 $2 2>/dev/null
		if [ $? -ne 0 ]; then
			loguear "E" "No se pudo mover el archivo ${1##*/}"
			return 1
		fi
	fi
}

function moverArchivos() {
	echo "Moviendo archivos..."

	moverArchivo "$GRUPO/$INSTDIR/encuestas.mae" "$GRUPO/$MAEDIR"
	moverArchivo "$GRUPO/$INSTDIR/preguntas.mae" "$GRUPO/$MAEDIR"
	moverArchivo "$GRUPO/$INSTDIR/encuestadores.mae" "$GRUPO/$MAEDIR"
	moverArchivo "$GRUPO/$INSTDIR/errores.mae" "$GRUPO/$MAEDIR"

	moverArchivo "$GRUPO/$INSTDIR/iniciarC.sh" "$GRUPO/$BINDIR"
	if [ $? -eq 0 ]; then
		INICIARU=$USER
		INICIARF=`date +"%F %T"`
	fi

	moverArchivo "$GRUPO/$INSTDIR/listarC.pl" "$GRUPO/$BINDIR"
	if [ $? -eq 0 ]; then
		LISTARU=$USER
		LISTARF=`date +"%F %T"`
	fi

	moverArchivo "$GRUPO/$INSTDIR/sumarC.sh" "$GRUPO/$BINDIR"
	if [ $? -eq 0 ]; then
		SUMARU=$USER
		SUMARF=`date +"%F %T"`
	fi

	moverArchivo "$GRUPO/$INSTDIR/detectarC.sh" "$GRUPO/$BINDIR"
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
#	 0: Instalacion completa
#	 1: Ningun componente instalado
#	 2: Instalacion incompleta  
function detectarInstalacion {
	cantInst=0
	cantNoInst=0
	unset instalados
	unset noinstalados
	
	if [ "$INICIARU" != "" ] && [ -f "$GRUPO/$BINDIR/iniciarC.sh" ]; then
		instalados[$cantInst]="iniciarC $INICIARU $INICIARF"
		let cantInst=cantInst+1
	else
		noinstalados[$cantNoInst]="iniciarC"
		let cantNoInst=cantNoInst+1
	fi 

	if [ "$DETECTARU" != "" ] && [ -f "$GRUPO/$BINDIR/detectarC.sh" ]; then
		instalados[$cantInst]="detectarC $DETECTARU $DETECTARF"
		let cantInst=cantInst+1
	else
		noinstalados[$cantNoInst]="detectarC"
		let cantNoInst=cantNoInst+1
	fi 
	
	if [ "$SUMARU" != "" ] && [ -f "$GRUPO/$BINDIR/sumarC.sh" ]; then
		instalados[$cantInst]="sumarC $SUMARU $SUMARF"
		let cantInst=cantInst+1
	else
		noinstalados[$cantNoInst]="sumarC"
		let cantNoInst=cantNoInst+1
	fi 

	if [ "$LISTARU" != "" ] && [ -f "$GRUPO/$BINDIR/listarC.pl" ]; then
		instalados[$cantInst]="listarC $LISTARU $LISTARF"
		let cantInst=cantInst+1
	else
		noinstalados[$cantNoInst]="listarC"
		let cantNoInst=cantNoInst+1
	fi 
	
	if [  $cantInst -gt 0 ]; then
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

	mensaje="********************************************************\n"
	mensaje+="*   Sistema Consultar Copyright SisOp (c)2011          *\n"
	mensaje+="********************************************************\n"
	
	if [ $cantInst -gt 0 ]; then
		mensaje+="* Se encuentran instalados los siguientes componentes:\n"
		arr=("${instalados[@]}")
		for index in ${!arr[*]}
		do
			mensaje+="* ${arr[$index]}\n"
		done
	fi

	if [ $cantNoInst -gt 0 ]; then 
		mensaje+="*						       *\n"
		mensaje+="* Falta instalar los siguientes componentes:           *\n"	
		for item in ${noinstalados[*]}
		do
			mensaje+="* $item\n"
		done
	fi
	echoAndLog "I" "$mensaje"
}

#-----------------------------------------------------------------------------------------------#
#----------------------------------------------MAIN---------------------------------------------#
#-----------------------------------------------------------------------------------------------#

loguear "I" "Inicio de Ejecucion"
clear
leerConfiguracion
detectarInstalacion
case "$?" in 
	0 ) 	#Instalacion completa
		mostrarComponentesInstalados
		echoAndLog "I" "* Proceso de Instalacion Cancelado\n"
		exit 0;;

	1 ) 	#No hay instalacion previa
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
echoAndLog "I" "* Fin del proceso de instalacion Copyright SisOp (c)2011"
echo "********************************************************" 
exit $?
