#!/bin/bash
#
# instalarC.sh
# Script para la instalacion del paquete Consultar
#
# Creado por Nicolas Suarez

GRUPO=`pwd`
INSTDIR="inst"
CONFDIR="conf"
MAEDIR="mae"
BINDIR="bin"
LIBDIR="lib"
ARRIDIR="$GRUPO/arribos"
DATASIZE=100 #MB
LOGDIR="$GRUPO/log"
LOGEXT=".log"
LOGSIZE=400 #KB
LOGFILE="$INSTDIR/instalarC.log"

function toLower() {
	echo $1 | tr "[:upper:]" "[:lower:]"
}

function loguear() {
	echo -e `date +"%F %T"` - $USER - instalarC - "$1" - "$2" >> $LOGFILE
}

function echoAndLog() {
	echo -e -n "$2"
	loguear "$1" "$2"
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
	echoAndLog "I" "Todos los directorios del sistema serán subdirectorios de $GRUPO\n"
	echoAndLog "I" "Todos los componentes de la instalación se obtendrán del repositorio: $GRUPO/$INSTDIR\n"
	listado=`ls $GRUPO/$INSTDIR`
	echoAndLog "I" "$listado\n"
	echoAndLog "I" "El log de la instalación se almacenara en $GRUPO/$INSTDIR\n"
	echoAndLog "I" "Al finalizar la instalación, si la misma fue exitosa se dejara un archivo de configuración en $GRUPO/$CONFDIR\n"
}

function definirDirBinarios() {
	isOk=0
	while [ "$isOk" -eq 0 ]; do
		echoAndLog "I" "Ingrese el nombre del directorio de ejecutables ($BINDIR):"
		read dirBin
		if [ \! -z "$dirBin" ]; then
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
		if [ \! -z "$dirArribos" ]; then
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
			if [ \! -z $dataSize ]; then
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
		if [ \! -z "$dirLog" ]; then
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
	if [ \! -z "$logExt" ]; then
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
	if [ \! -z $logSize ]; then
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

function confirmarParametros() {
	echo `clear`
	mensaje="**********************************************************************\n"
	mensaje+="*\n"
	mensaje+="* Parámetros de Instalación del paquete  Consultar\n"
	mensaje+="*\n"
	mensaje+="**********************************************************************\n"
	mensaje+="Directorio de trabajo: $GRUPO\n"
	mensaje+="Directorio de instalación: $GRUPO/$INSTDIR\n"
	mensaje+="Directorio de configuración: $GRUPO/$CONFDIR\n"
	mensaje+="Directorio de datos maestros: $GRUPO/$MAEDIR\n"
	mensaje+="Directorio de ejecutables: $GRUPO/$BINDIR\n"
	mensaje+="Librería de funciones: $GRUPO/lib\n"
	mensaje+="Directorio de arribos: $ARRIDIR\n"
	mensaje+="Espacio mínimo reservado en $ARRIDIR: $DATASIZE MB\n"
	mensaje+="Directorio para los archivos de Log: $LOGDIR\n"
	mensaje+="Extensión para los archivos de Log: $LOGEXT\n"
	mensaje+="Tamaño máximo para cada archivo de Log: $LOGSIZE Kb\n"
	mensaje+="Log de la instalación: $GRUPO/$INSTDIR\n\n"
	mensaje+="Si los datos ingresados son correctos de ENTER para continuar, si\n"
	mensaje+="desea modificar algún parámetro oprima cualquier tecla para reiniciar\n"
	echoAndLog "I" "$mensaje"	
	read -s -n1 respuesta

	if [ "$respuesta" = "" ]; then
		return 0
	else
		return 1
	fi
}

#-----------------------------------------------------------------------------------------------#
#----------------------------------------------MAIN---------------------------------------------#
#-----------------------------------------------------------------------------------------------#

loguear "I" "Inicio de Ejecucion"

#TODO: Detectar Instalacion
terminosCondiciones
verificarPerl
mensajesInformativos

modifica=1
while [ $modifica -ne 0 ]; do
	definirDirBinarios
	definirDirArribos
	definirDirLog
	confirmarParametros
	modifica=$?
done

echo "Iniciando Instalación… Está UD. seguro? (Si/No)"
#TODO: Crear estructura de directorios
#TODO: Mover archivos binarios y maestros
#TODO: Actualizar archivo de configuracion

