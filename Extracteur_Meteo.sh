#!/bin/bash
if [ "$1" = "" ];
then
    echo "usage:$0 <ville>"
    exit 1
fi
Ville=$1
Date=$(date  +"%Y-%m-%d %H:%M:%S")
Fichier="meteo_${Ville}.txt"
Meteo=$(curl -s "https://wttr.in/${Ville}?format=3")
if [ "$Meteo" = "" ];
then
    echo "erreur!impossible de recuperer la meteo"
    exit 2
fi
echo "$Date	$Meteo" >> "$Fichier"
echo "meteo enregistree dans $Fichier"
