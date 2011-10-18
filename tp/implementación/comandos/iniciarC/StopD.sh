#!/bin/bash
# StopD - Detiene el daemon detectarC
MENSAJE_ERROR="El deamond detectarC.sh no esta corriendo"
MENSAJE_OK="Se detuvo la ejecucion del deamond detectarC.sh" 

PID=`ps | grep "detectarC.sh" | head -1 | awk '{print $1 }'`

if [ -z $PID  ]; then
	$GRUPO/$LIBDIR/loguearC.sh -w -t E -m "$MENSAJE_ERROR" -p "StopD"
	echo "$MENSAJE_ERROR"
else
	kill -KILL $PID
	$GRUPO/$LIBDIR/loguearC.sh -w -t I -m "$MENSAJE_OK (PID: $PID) " -p "StopD"
	echo "$MENSAJE_OK (PID: $PID)"
fi
