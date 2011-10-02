#!/bin/bash
#
# instalarC.sh
# Script para la instalacion del paquete Consultar
#
# Creado por Nicolas Suarez

logFile="inst/instalarC.log"

function toLower() {
	echo $1 | tr "[:upper:]" "[:lower:]"
}

function toUpper() {
	echo $1 | tr "[:lower:]" "[:upper:]"
}

function loguear() {
	echo -e `date +"%F %T"` - $USER - instalarC - "$1" - "$2" >> $logFile
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
	read response
	
	loguear "I" "$mensaje$response"
	
	if [ `toLower $response` = "n" ]; then
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

#main

loguear "I" "Inicio de Ejecucion"

terminosCondiciones

verificarPerl
