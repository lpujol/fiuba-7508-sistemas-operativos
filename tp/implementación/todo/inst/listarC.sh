#!/bin/bash

#
# $Id:$
#



#descomentar proxima linea en produccion y comentar la siguiente
PLIST_PARAMETERS="$BENEFICIOS"
#PLIST_PARAMETERS="procesados/"

for var in "$@"
do
    PLIST_PARAMETERS=$PLIST_PARAMETERS" "$var
done


perl plist.pl $PLIST_PARAMETERS

