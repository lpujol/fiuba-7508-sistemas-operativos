#!/bin/bash
# StopD - Detiene el daemon detectarC
PID=`ps | grep "detectarC.sh" | head -1 | awk '{print $1 }'`
kill -KILL $PID
