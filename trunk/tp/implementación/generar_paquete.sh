#!/bin/bash
#
# Script para generar el paquete de instalacion a partir de nuestra estructura
# de carpetas
#
# This script generates the installation package given our folder structure.

NOMBRE="tp-grupo01"

mkdir $NOMBRE
mkdir $NOMBRE/inst
if [ "$(ls -1tr todo/inst)" ]; then
    cp todo/inst/* $NOMBRE/inst
fi
if [ "$(ls -1tr todo/lib)" ]; then
    cp todo/lib/* $NOMBRE/inst
fi
if [ "$(ls -1tr todo/ya)" ]; then
    cp todo/ya/* $NOMBRE/inst
fi
if [ "$(ls -1tr todo/mae)" ]; then
    cp todo/mae/* $NOMBRE/inst
fi
mv $NOMBRE/inst/instalarC.sh $NOMBRE
cp README $NOMBRE # README esta en la misma carpeta que este script
tar czf $NOMBRE.tgz $NOMBRE
rm -r $NOMBRE
