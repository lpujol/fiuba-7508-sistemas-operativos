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
$grupo='/home/havoc/tpMy'
#Ambiente iniciado?
#Hier das tolle Programm da nutzen
if [ -z $grupo ] 
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
  LOGDIR=$grupo/log
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

# Parameter parsen
echo parse
while getopts t:p:m: option
do	
case "$option" in
  	t)	echo Tipo de Mensaje: $OPTARG;logtipo=$OPTARG;;
  	p)	echo Programa: $OPTARG;logprog=$OPTARG;;
	m)	echo Text: $OPTARG;logmsg=$OPTARG;;
	[?])	echo "Opciones posibles: t p m"
	esac
done

#Hay parametro de Mensaje?
if [ -z "$logmsg" ] 
  then
    echo Falta el texto de la mensaje
    exit 1
fi

#Hay parametro de nombre de programa?
#Prüfen ob es ein gültiger Name ist? Oder egal?
if [ -z $logprog ] 
  then
    echo Falta nombre de programa
    exit 1
fi

#Hay parametro de tipo de mensaje?
if [ -z $logtipo ] 
  then
    echo Falta tipo de mensaje
    exit 1
fi

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
if [ -n $logtipo2 ]
  then
  echo Erweiterter Parameter: $logtipo2  
#Default Texte für Erweiterte Fehler
#Master Datei verwenden?
#ODer die ganze Ersetzung nur beim LEsen des Logs machen --> Dateigröße
  case $logtipo2 in
    101) logmsg="$logtipo2: Datei nicht gefunden: $logmsg" ;;
    *) logmsg="$logtipo2: Unbekannter Code: $logmsg" ;;
  esac
fi

#Parameterreihenfolge?

#Datensatz schreiben
logentry="$logtime,$logusuario,$logtipo,$logmsg"
#Esistiert Datei?
logfile=$LOGDIR/$logprog$LOGEXT 
if [ \! -w $logfile ]
  then
  #Existe el directorio?
  if [ \! -d $LOGDIR ]
    then
    mkdir $LOGDIR
  fi
  #Grabar mensaje en log
  lognewentry="$logtime,$logusuario,A,554:Log $logfile no existe, crear nuevo archivo de log"
  echo "$lognewentry" >> $logfile
fi

#Dateigröße prüfen
#vorher oder nachher? einfach den satz mit aufnehmen
logsize=`stat -c "%s" $logfile`
echo $logsize
echo $MAXLOGSIZE
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
  echo "$logfullentry" >> $logfile
  #NAchricht an Benutzer
  echo "Log excedido, había más de $MAXLOGSIZE kb, se corta"
fi

#Schreiben
#evtl Fehler auswertem
echo "$logentry" >> $logfile

exit 0
