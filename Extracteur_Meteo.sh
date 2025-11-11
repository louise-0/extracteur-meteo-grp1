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
#partie 2

git add Extracteur_Meteo.sh
git commit -m " ajout de la partie 2 pour récupération météo"
git push origin version1

TempActuelle=$(curl -s "https://wttr.in/${Ville}?format=%t")
TempDemain=$(curl -s "https://wttr.in/${Ville}?1" | grep -oE '[+-]?[0-9]+°C' | sed -n '2p')
if [ -z "$TempDemain" ]; then
    TempDemain="N/A"
fi
Jour=$(date +"%Y-%m-%d")
Heure=$(date +"%H:%M")
Ligne="${Jour} - ${Heure} - ${Ville} : ${TempActuelle} - ${TempDemain}"
echo "$Ligne" >> meteo.txt
echo "Données formatées enregistrées dans meteo.txt"

