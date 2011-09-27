#! /bin/bash            
#
#
# loguer.sh
# Script parar crear logs
#
# de Nikolaus Schneider para el trabajo practico
# de la MAteria Sistemas Operativos
#
# last change: 2011-09-25

echo Vamos!

#Fragen
#1 1 Log oder viele?
#2 Prüfung nach laufenden Prozessen? Eigentlich egal, soll aber


#Exit-Codes
#  0 - Esta bien
#  1 - Faltan Parametros
#  2 - No puede escribir
#  3 - Ambiente no iniciado
 
#Umgebungsvariablen, später löschen
LOGDIR="log"
LOGEXT=".log"

#Ambiente iniciado?
if [ -z $LOGDIR ] || [ -z $LOGEXT ]
  then
    echo Fehlt was
    exit 1
fi
 

#Variablen
logmsg="Text"
logprog=""
logtime="time" 
logtipo="tipo de Mensaje"

# Parameter parsen
echo parse
while getopts a:b option
do	
case "$option" in
  	t)	echo Tipo de Mensaje: $OPTARG;logtipo=$OPTARG;;
  	p)	echo Programa: $OPTARG;logprog=$OPTARG;;
	m)	echo Text: $OPTARG;logmsg=$OPTARG;;
	[?])	echo "Usage: bbbb"
	esac
done

#Weitere Angaben ermitteln

#User
#Zeit
#Einf Format für Zeit
logtime=`date "+%y-%m-%d_%H-%M-%S"`
echo $logtime

#Alternativ Sekunden seit 1970, ist kürzer
date '+%s'

#Dateiname mit Pfad des Logs
#Prüfen ob es ein gültiger Name ist? Oder egal?
#Und prüfen ob der Parameter gesetzt ist
if [ -z $logproc ] 
  then
    echo Kein Programmname übergeben
    exit 1
fi
logfile=$logprog$LOGEXT 


#Parameterreihenfolge?


#Datensatz schreiben
#Esistiert Datei?
if [ \! -w $logfile ]
  then
#Datensatzformat gem Standard
  echo "Nuevo log de $logtime" > $logfile
fi

#Dateigröße prüfen

#Schreiben
echo Datensatz: $logtime,$logtipo,$logmsg >> $logfile

