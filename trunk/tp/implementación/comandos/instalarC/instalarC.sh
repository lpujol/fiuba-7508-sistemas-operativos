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

function toUpper() {
	echo $1 | tr "[:lower:]" "[:upper:]"
}

function loguear() {
	echo -e `date +"%F %T"` - $USER - instalarC - "$1" - "$2" >> $LOGFILE
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
	echo -n -e "$mensaje"
	read respuesta
	
	loguear "I" "$mensaje$respuesta"
	
	if [ `toLower $respuesta` = "n" ]; then
		loguear "I" "Instalacion Cancelada"
		exit 1
	fi
}

function verificarPerl() {
	perlVersion=`perl --version | grep -o "v[5-9][0-9]\{0,\}.[0-9]\{1,\}.[0.9]\{0,\}"`

	if [ $? -eq 1 ]; then
		mensaje="Para instalar Consultar es necesario contar con  Perl 5 o superior instalado.\n"
		mensaje+="Efectúe su instalación e inténtelo nuevamente. Proceso de Instalación Cancelado."
		echo -e $mensaje
		loguear "SE" "$mensaje"
		exit 1
	else
		loguear "I" "Version de Perl instalada: $perlVersion"
	fi
}

function imprimirParametros() {
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
	mensaje+="Espacio mínimo reservado en $ARRIDIR: $DATASIZE Mb\n"
	mensaje+="Directorio para los archivos de Log: $LOGDIR\n"
	mensaje+="Extensión para los archivos de Log: $LOGEXT\n"
	mensaje+="Tamaño máximo para cada archivo de Log: $LOGSIZE Kb\n"
	mensaje+="Log de la instalación: $GRUPO/$INSTDIR\n\n"
	mensaje+="Si los datos ingresados son correctos de ENTER para continuar, si\n"
	mensaje+="desea modificar algún parámetro oprima cualquier tecla para reiniciar\n"
	mensaje+="*********************************************************************\n"	

	echo -e "$mensaje"
	loguear "I" "$mensaje"
	
	read -s -n1 respuesta

	if [ "$respuesta" = "" ]; then
		echo "Iniciando Instalación… Está UD. seguro? (Si/No)"
	else
		echo "Cambiar parametros"
	fi
}
#main

loguear "I" "Inicio de Ejecucion"

terminosCondiciones

verificarPerl

imprimirParametros
