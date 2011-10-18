CONFFILE="../conf/instalarC.conf"

function checkearEntornoNoIniciado(){
	cantSeteado=0
	unset seteados
	if [ "$GRUPO" != "" ]; then
		seteados[$cantSeteado]="GRUPO="$GRUPO
		let cantSeteado=cantSeteado+1
	fi
	if [ "$CONFDIR" != "" ]; then
		seteados[$cantSeteado]="CONFDIR="$CONFDIR
		let cantSeteado=cantSeteado+1
	fi
	if [ "$DATAMAE" != "" ]; then
		seteados[$cantSeteado]="DATAMAE="$DATAMAE
		let cantSeteado=cantSeteado+1
	fi
	if [ "$LIBDIR" != "" ]; then
		seteados[$cantSeteado]="LIBDIR="$LIBDIR
		let cantSeteado=cantSeteado+1
	fi
	if [ "$BINDIR" != "" ]; then
		seteados[$cantSeteado]="BINDIR="$BINDIR
		let cantSeteado=cantSeteado+1
	fi
	if [ "$ARRIDIR" != "" ]; then
		seteados[$cantSeteado]="ARRIDIR="$ARRIDIR
		let cantSeteado=cantSeteado+1
	fi
	if [ "$DATASIZE" != "" ]; then
		seteados[$cantSeteado]="DATASIZE="$DATASIZE
		let cantSeteado=cantSeteado+1
	fi
	if [ "$LOGSIZE" != "" ]; then
		seteados[$cantSeteado]="LOGSIZE="$LOGSIZE
		let cantSeteado=cantSeteado+1
	fi
	if [ "$LOGDIR" != "" ]; then
		seteados[$cantSeteado]="LOGDIR="$LOGDIR
		let cantSeteado=cantSeteado+1
	fi
	if [ "$LOGEXT" != "" ]; then
		seteados[$cantSeteado]="LOGEXT="$LOGEXT
		let cantSeteado=cantSeteado+1
	fi
	if [ $cantSeteado -gt 0 ]; then 
		status=1 #Entorno ya iniciado
	else
		status=0 #Entorno limpio
	fi		
	return $status
			

}


function cargarVariables() {
		
	if [ -f $CONFFILE ]; then
		if [ "$GRUPO" == "" ]; then
			GRUPO=`grep "CURRDIR" $CONFFILE | cut -s -f2 -d'='`
		fi
		export GRUPO	
		if [ "$CONFDIR" == "" ]; then
			CONFDIR=`grep "CONFDIR" $CONFFILE | cut -s -f2 -d'='`
		fi	
		export CONFDIR
		if [ "$DATAMAE" == "" ]; then
			DATAMAE=`grep "DATAMAE" $CONFFILE | cut -s -f2 -d'='`	
		fi
		export DATAMAE
		if [ "$LIBDIR" == "" ]; then
			LIBDIR=`grep "LIBDIR" $CONFFILE | cut -s -f2 -d'='`
		fi	
		export LIBDIR
		if [ "$BINDIR" == "" ]; then
			BINDIR=`grep "BINDIR" $CONFFILE | cut -s -f2 -d'='`
		fi	
		export BINDIR
		if [ "$ARRIDIR" == "" ]; then
			ARRIDIR=`grep "ARRIDIR" $CONFFILE | cut -s -f2 -d'='`
		fi	
		export ARRIDIR
		if [ "$DATASIZE" == "" ]; then
			DATASIZE=`grep "DATASIZE" $CONFFILE | cut -s -f2 -d'='`	
		fi
		export DATASIZE
		if [ "$LOGSIZE" == "" ]; then
			LOGSIZE=`grep "MAXLOGSIZE" $CONFFILE | cut -s -f2 -d'='`
		fi
		export LOGSIZE	
		if [ "$LOGDIR" == "" ]; then
			LOGDIR=`grep "LOGDIR" $CONFFILE | cut -s -f2 -d'='`	
		fi
		export LOGDIR
		if [ "$LOGEXT" == "" ]; then
			LOGEXT=`grep "LOGEXT" $CONFFILE | cut -s -f2 -d'='`
		fi
		export LOGEXT			
	fi	
	PATH=$PATH:$GRUPO:$GRUPO/$BINDIR"/"
	export PATH
}

function checkearInstalacion(){
	cantFalta=0
	unset faltantes
	if [ ! -f $GRUPO"/"$DATAMAE"/encuestas.mae" ]; then
		faltantes[$cantFalta]=$GRUPO"/"$DATAMAE"/encuestas.mae"
		let cantFalta=cantFalta+1
	fi
	if [ ! -f $GRUPO"/"$DATAMAE"/preguntas.mae" ]; then
		faltantes[$cantFalta]=$GRUPO"/"$DATAMAE"/preguntas.mae"
		let cantFalta=cantFalta+1
	fi
	if [ ! -f $GRUPO"/"$DATAMAE"/encuestadores.mae" ]; then
		faltantes[$cantFalta]=$GRUPO"/"$DATAMAE"/encuestadores.mae"
		let cantFalta=cantFalta+1
	fi
	if [ ! -f $GRUPO"/"$DATAMAE"/errores.mae" ]; then
		faltantes[$cantFalta]=$GRUPO"/"$DATAMAE"/errores.mae"
		let cantFalta=cantFalta+1
	fi
	if [ $cantFalta -gt 0 ]; then 
		status=1 #Instalacion corrupta
	else
		status=0 #Instalacion Ok
	fi		
	return $status
	return 0
}

function otorgarPermisoEjecucion(){
	chmod +x ../lib/StartD.sh
	chmod +x detectarC.sh
}

function checkearDetectarC(){
	PIDDETECTARC=`ps | grep "detectarC.sh" | head -1 | awk '{print $1 }'`	
	if [ "$PIDDETECTARC" != "" ]; then
		return $PIDDETECTARC
	fi
	return 0
}

function iniciarDetectarC(){
	../lib/StartD.sh ../bin/detectarC.sh
	PIDDETECTARC=`ps | grep "detectarC.sh" | head -1 | awk '{print $1 }'`	
	if [ "$PIDDETECTARC" != "" ]; then
		return $PIDDETECTARC
	fi
	return 0
}

checkearEntornoNoIniciado
	if [ $? -eq 1 ]; then
		echo "Advertencia: Hay variables que ya contienen valor."	
		echo "Se encuentran seteadas las siguientes variables:"
		arr=("${seteados[@]}")
		for index in ${!arr[*]}
		do
			echo "- ${arr[$index]}"
		done				
	fi
cargarVariables
checkearInstalacion
	if [ $? -eq 1 ]; then
		echo "Inicialización de Ambiente No fue exitosa."
		echo "Error: No se encuentran archivos necesarios"
		arr=("${faltantes[@]}")
		for index in ${!arr[*]}
		do
			echo "- ${arr[$index]}"
		done
		return 1
	fi
otorgarPermisoEjecucion
checkearDetectarC
	if [ $? -ne 0 ]; then
		echo "DetectarC ya se encuentra ejecutando bajo el Numero:$PIDDETECTARC?"
		return 1
	fi
iniciarDetectarC
	if [ $? -ne 0 ]; then
		pidd=$?
		echo "Inicialización de ambiente concluida"
		echo "Ambiente:"
		echo "-GRUPO=$GRUPO"
		echo "-CONFDIR=$CONFDIR"
		echo "-DATAMAE=$DATAMAE"
		echo "-LIBDIR=$LIBDIR"
		echo "-BINDIR=$BINDIR"
		echo "-ARRIDIR=$ARRIDIR"
		echo "-DATASIZE=$DATASIZE"
		echo "-LOGSIZE=$LOGSIZE"
		echo "-LOGDIR=$LOGDIR"
		echo "-LOGEXT=$LOGEXT"
		echo "Demonio corriendo bajo el Nro:$PIDDETECTARC"
		return 0
	else
		echo "Inicialización de Ambiente No fue exitosa."
		echo "Error: No se pudo iniciar el Demonio"
	fi

