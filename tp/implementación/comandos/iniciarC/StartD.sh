#!/bin/bash
# StartD - Inicia el daemon detectarC
nohup $GRUPO/$BINDIR/detectarC.sh > /dev/null 2>&1 &
