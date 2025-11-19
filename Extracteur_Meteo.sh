#!/bin/bash

ville_par_defaut="Toulouse"
ville=""
option=""

if [ "$1" == "--archive" ]; 
then
    option="--archive"
    ville="$2"
else
    ville="$1"
    option="$2"
fi

if [ -z "$ville" ]; 
then
    ville=$ville_par_defaut
fi

temp_fichier_txt="meteo_temp.txt"
fichier_sortie="meteo.txt"

if [ "$option" == "--archive" ]; 
then
    date_actuelle=$(date +"%Y%m%d")
    fichier_sortie="meteo_${date_actuelle}.txt"
fi

curl -s "wttr.in/${ville}?format=3" -o "$temp_fichier_txt"

temp_actuelle=$(cut -d':' -f2 "$temp_fichier_txt" | xargs)

date_du_jour=$(date +"%Y-%m-%d")
heure_actuelle=$(date +"%H:%M")

ligne="${date_du_jour} - ${heure_actuelle} - ${ville} : ${temp_actuelle} "

echo "$ligne" >> "$fichier_sortie"

rm "$temp_fichier_txt"

echo "$ligne"

