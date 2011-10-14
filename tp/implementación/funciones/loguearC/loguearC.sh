#! /bin/bash            
#
#
# loguer.sh
# Script parar crear logs
#
# de Nikolaus Schneider para el trabajo practico
# de la MAteria Sistemas Operativos
#
# last change: 2011-10-02

#Fragen
#1 1 Log oder viele?
#2 Prüfung nach laufenden Prozessen? Eigentlich egal, soll aber


#Exit-Codes
#  0 - Esta bien
#  1 - Faltan Parametros
#  2 - No puede escribir
#  3 - Ambiente no iniciado


#Funcion para grabar en el log
#Parametros
#1 - Texto para grabar
#2 - Nombre de archivo
function grabarLog
{
  echo "$1" >> $2
  if [ $? -ne 0 ]
    then
    echo No Puede escribir en el archivo $2
    exit 2 
  fi
}

#Funcion para examinar la exestencia de una variable
#1 - Variable
#2 - Texto si no existe
function existeParametro
{
  if [ -z "$1" ] 
    then
      echo $2
      exit 1
  fi
}

#Funcion para examir las entradas y al final grabar el log
function writeLog
{
#Hay parametro de Mensaje?
existeParametro "$logmsg" "Falta el texto de la mensaje"

#Hay parametro de nombre de programa?
#Prüfen ob es ein gültiger Name ist? Oder egal?
existeParametro "$logprog" "Falta el nombre de la programa"

#Hay parametro de tipo de mensaje?
existeParametro "$logtipo" "Falta tipo de mensaje"

#Determinar otros datos

#Usuario
logusuario=$USER

#Zeit
#Ein Format für Zeit
logtime=`date "+%y-%m-%d_%H-%M-%S"`

#Alternativ Sekunden seit 1970, ist kürzer
#date '+%s'

#Tipo de Mensaje
#Posibilidad a usar solo eg 'I', o con numero
#para errores communes
#MEldung bei ungültige rFehlernummer? Im moment nur zahlen
logtipo2=`echo $logtipo | sed  's/^\(E\|A\|I\|SE\)\([0-9]*\)/\2/'`
logtipo=`echo $logtipo | sed  's/^\(E\|A\|I\|SE\)\([0-9]*\)/\1/'`
if [ ${#logtipo2} -gt 0 ]
  then
  #Default Texte für Erweiterte Fehler
  #Existe Archivo de maestro?
  if [ \! -f "$DATAMAE/errores.mae" ]
    then
    echo No encuentro el maestro de errores
  fi
  logmsg=`sed -n "s/^\($logtipo2\),\(.*\)/\1: \2 $logmsg/p" "$DATAMAE/errores.mae"`
fi

#Parameterreihenfolge?

#Datensatz schreiben
logentry="$logtime,$logusuario,$logtipo,$logmsg"
logfile=$LOGDIR/$logprog.$LOGEXT 

#Existe Archivo de log?
if [ \! -w $logfile ]
  then
  #Existe el directorio?
  if [ \! -d $LOGDIR ]
    then
    mkdir $LOGDIR
  fi
  
  #Grabar mensaje en log
  lognewentry="$logtime,$logusuario,A,554:Log $logfile no existe, crear nuevo archivo de log"
  grabarLog "$lognewentry" "$logfile"
fi

#Examinar tamano de archivo de log
logsize=`stat -c "%s" $logfile`
if [ $logsize -gt `expr $MAXLOGSIZE \* 1024 - ${#logentry}` ]
  then
  #Verfahren? 50 Prozent, oder erst info oder so löschen?
  #Erstmal hart abschneiden
  #50 Prozent der Linien
  #Zeilenanzahl 
  loglines=`grep -c '' $logfile`
  sed -i "1,`expr $loglines \/ 2` d" $logfile
  
  #Nachricht irgendwo dokumentieren, andere haben ja auch filesize dinger
  logfullentry="$logtime,$logusuario,A,555:Log excedido, había más de $MAXLOGSIZE kb, se corta"
  grabarLog "$logfullentry" "$logfile"
  
  #Mensaje a stdout
  echo "Log excedido, había más de $MAXLOGSIZE kb, se corta"
fi

#Escribir
grabarLog "$logentry" "$logfile"
}

#funcion parar mirar los archivos de log
function viewLog
{
  echo mirando

  #Hay parametro de nombre de programa?
  existeParametro "$logprog" "Falta el nombre de la programa"

  #Existe Archivo de log?
  logfile="$LOGDIR/$logprog.$LOGEXT" 

  if [ \! -f $logfile ]
    then
    echo No encuentro el archivo $logfile
  fi

  #beim anzeigen mehr als ein typ möglich?
  #tipo splitten
  logtipo2=`echo $logtipo | sed  's/^\(E\|A\|I\|SE\)\([0-9]*\)/\2/'`
  logtipo=`echo $logtipo | sed  's/^\(E\|A\|I\|SE\)\([0-9]*\)/\1/'`

  #Opcion 'ver n lineas'
  #Gilt ja generell, also zuletzt
  if [ -z $logviewlineas ]
    then
    grep  "^\([^,]*\)[,]\([^,]*\)[,]\([^,]*\)$logtipo\([^,]*\)[,][^,]*$logtipo2" "$logfile" | grep  "^\([^,]*\)[,]\([^,]*\)[,]\([^,]*\)[,]\([^,]*\)$logmsg"
else 
    grep  "^\([^,]*\)[,]\([^,]*\)[,]\([^,]*\)$logtipo\([^,]*\)[,][^,]*$logtipo2" "$logfile" | grep  "^\([^,]*\)[,]\([^,]*\)[,]\([^,]*\)[,]\([^,]*\)$logmsg" | tail -$logviewlineas
  fi
} #fin de viewLog

 
#Umgebungsvariablen, später löschen
#grupo='/home/havoc/tpMy'

#DATAMAE="$GRUPO/mae"

#Ambiente iniciado?
#Hier das tolle Programm da nutzen
if [ -z $GRUPO ] 
  then
    echo Falta Ambiente
    exit 3
fi

if [ -z $MAXLOGSIZE ]
  then
  MAXLOGSIZE=100
fi

if [ -z $LOGDIR ]
  then
  LOGDIR=$GRUPO/log
fi

if [ -z $LOGEXT ]
  then
  LOGEXT=log
fi


#Variablen
logmsg=""
logprog=""
logtime="" 
logtipo="" 
logtipo2=""
logusuario=""
logmode="view"
logviewlinieas=""


# Parameter parsen
while getopts t:p:m:wn:s: option
do	
case "$option" in
  	t)	logtipo=$OPTARG;;
  	p)	logprog=$OPTARG;;
	m)	logmsg=$OPTARG;;
	w)	logmode="write";;
	n)	logviewlineas=$OPTARG;;
	[?])	echo "Opciones posibles: t p m w"
	esac
done

#Estamos mirando o escribiendo?
if [ $logmode = "write" ]
  then
  writeLog
elif [ $logmode = "view" ]
  then
  viewLog
fi


echo Listo
exit 0
