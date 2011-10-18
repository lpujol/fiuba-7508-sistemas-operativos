#! /bin/bash            
#
#
# loguer.sh
# Script parar crear logs
#
# de Nikolaus Schneider para el trabajo practico
# de la Materia Sistemas Operativos
#
# last change: 2011-10-16

#Códigos de retorno
	#  0 - Esta bien
	#  1 - Faltan Parametros
	#  2 - No puede escribir
	#  3 - Ambiente no iniciado
	#  4 - Parametro inválido
	#  5 - Archivo de log no existente


#Funcion para grabar en el log
#Parametros
#1 - Texto para grabar
#2 - Nombre de archivo
function grabarLog
{
	echo "$1" >> $2
	if [ $? -ne 0 ]; then
		echo No Puede escribir en el archivo $2
		exit 2 
	fi
}

#Funcion para examinar la exestencia de una variable
#1 - Variable
#2 - Texto si no existe
function existeParametro
{
	if [ -z "$1" ]; then
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
	existeParametro "$logprog" "Falta el nombre de la programa"
	if [ `echo "$logprog" | grep -c "^[a-zA-Z0-9]*$"` -eq 0 ]; then
		echo Nombre de programa inválido: $logprog 
		exit 4
	fi

	#Hay parametro de tipo de mensaje?
	existeParametro "$logtipo" "Falta tipo de mensaje"

	#Determinar otros datos
	#Usuario
	logusuario=$USER

	#Tiempo
	logtime=`date "+%y-%m-%d_%H-%M-%S"`

	#Existe Archivo de log?
	logfile=$GRUPO/$LOGDIR/$logprog$LOGEXT 
	if [ \! -w $logfile ]; then
		#Existe el directorio?
		if [ \! -d $LOGDIR ]; then
			mkdir $LOGDIR
		fi
		#Grabar mensaje en log
		lognewentry="$logtime,$logusuario,A998,LoguearC:Log no existe, crear nuevo archivo de log: $logfile"
		grabarLog "$lognewentry" "$logfile"
	fi

	#Hay characteres ilegales en el logmsg? --> Sustituir
	if [ `echo "$logmsg" | grep -c "[|*]"` -gt 0 ]; then
		logmsg=`echo "$logmsg" | sed  's-[|*]--g'`
		echo Sustituyo characteres en el mensaje
		logcharmae="$logtime,$logusuario,E997,LoguearC:Sustitution de characteres en el mensaje"
		grabarLog "$logcharmae" "$logfile"
	fi

	#Tipo de Mensaje
	#Posibilidad a usar solo eg 'I', o con numero para errores communes
	#MEldung bei ungültige rFehlernummer? Im moment nur zahlen
	logtipo2=`echo $logtipo | sed  's/^\(E\|A\|I\|SE\)\([0-9]*\)$/\2/'`
	if [ ${#logtipo2} -gt 0 ]; then
		#Existe Archivo de maestro?
		if [ \! -f "$GRUPO/$DATAMAE/errores.mae" ]; then
			echo No encuentro el maestro de errores
			logfaltamae="$logtime,$logusuario,E999,LoguearC:Maestro de errores no existe, siguiente Mensaje sin este información"
			grabarLog "$logfaltamae" "$logfile"
		else
			logmsg=`sed -n "s|^\($logtipo2\),\(.*\)|\2: $logmsg|p" "$GRUPO/$DATAMAE/errores.mae"`
		fi
	fi

	#Parameterreihenfolge?

	#Prepara linea para grabar
	logentry="$logtime,$logusuario,$logtipo,$logmsg"

	#Examinar tamano de archivo de log
	logsize=`stat -c "%s" $logfile`
	if [ $logsize -gt `expr $MAXLOGSIZE \* 1024 - ${#logentry}` ]; then
		#Si esta demasiado grande, borrar 50 porcientos de las lineas
		#Calcular numero de lineas 
		loglines=`grep -c '' $logfile`
		sed -i "1,`expr $loglines \/ 2` d" $logfile

		logfullentry="$logtime,$logusuario,A500,Log excedido, se corta: había más de $MAXLOGSIZE kb,"
		grabarLog "$logfullentry" "$logfile"

		#Mensaje a stdout
		echo "Log excedido, había más de $MAXLOGSIZE kb, se corta"
	fi

	#Escribir
	grabarLog "$logentry" "$logfile"
} #fin de writeLog

#Funcion parar mirar los archivos de log
function viewLog
{
	#Hay parametro de nombre de programa?
	existeParametro "$logprog" "Falta el nombre de la programa"

	#Existe Archivo de log?
	logfile="$GRUPO/$LOGDIR/$logprog$LOGEXT" 

	if [ \! -f $logfile ]; then
		echo No encuentro el archivo $logfile
		exit 5
	fi

	#Tipo de Mensaje
	logtipo2=`echo $logtipo | sed  's/^\(E\|A\|I\|SE\)\([0-9]*\)/\2/'`

	#Opcion 'ver n lineas'
	if [ -z $logviewlineas ]; then
		grep  "^\([^,]*\)[,]\([^,]*\)[,]\([^,]*\)$logtipo\([^,]*\)[,][^,]*$logmsg" "$logfile" 
	else 
		grep  "^\([^,]*\)[,]\([^,]*\)[,]\([^,]*\)$logtipo\([^,]*\)[,][^,]*$logmsg" "$logfile" | tail -$logviewlineas
	fi
} #fin de viewLog

#Ambiente iniciado?
if [ -z $GRUPO ] 
  then
    echo Falta Ambiente
    exit 3
fi

#Poner variables, si no existen
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
  LOGEXT=".log"
fi

#Borar variables
logmsg=""
logprog=""
logtime="" 
logtipo="" 
logtipo2=""
logusuario=""
logmode="view"
logviewlinieas=""

#Parse parametros
while getopts t:p:m:wvn:s: option
do	
case "$option" in
  	t)	logtipo=$OPTARG;;
  	p)	logprog=$OPTARG;;
	m)	logmsg=$OPTARG;;
	w)	logmode="write";;
	v)	logmode="view";;
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

#Termina sin error
exit 0

