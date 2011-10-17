#!/bin/bash
#
# Script para generar el paquete de instalacion a partir de nuestra estructura
# de carpetas
#
# This script generates the installation package given out folder structure.

NOMBRE="tp-grupo01"

mkdir $NOMBRE
mkdir $NOMBRE/inst
cp todo/lib/* $NOMBRE/inst
cp todo/ya/* $NOMBRE/inst
cp todo/mae/* $NOMBRE/inst
mv $NOMBRE/inst/instalarC.sh $NOMBRE
tar czf $NOMBRE.tgz $NOMBRE
rm -r $NOMBRE
