#!/bin/bash

#Toulouse par defaut si aucun argument
Ville="Toulouse"

#option Json de sauvegarde
Json=false
if [ "$1" == "--json" ]; 
then
    Json=true
elif [ -n "$1" ]; 
then
    Ville="$1"
    if [ "$2" == "--json" ]; 
then
        Json=true
    fi
fi

Date=$(date +"%Y-%m-%d")
Heure=$(date +"%H:%M")

#recuperation des donnes meterologique
curl -s "https://wttr.in/${VILLE}?format=j1" > meteo_temp.txt

Temperature_actuelle=$(grep -m1 '"temp_C"' meteo_temp.txt | sed 's/[^0-9\-]//g')
Temperature_lendemain=$(grep -m1 '"avgtempC"' meteo_temp.txt | sed 's/[^0-9\-]//g')

#valeurs par defaut si non trouvees
[ -z "$Temperature_actuelle" ] && Temperature_actuelle="Meteo actuelle non disponible"
[ -z "$Temperature_lendemain" ] && Temperature_lendemain="Meteo de lendemain non disponible"

echo "$Date - $Heure - $Ville : $Temperature_actuelle°C - $Temperature_lendemain°C"

#sauvegarde sous forme Json
if $Json; 
then
    #ecriture Json simple
    cat <<EOF > meteo.json
{
  "date": "$DATE",
  "heure": "$HEURE",
  "ville": "$VILLE",
  "temperature": "${TEMP_ACTUELLE}°C",
  "prevision": "${TEMP_DEMAIN}°C"
}
EOF
    echo "Meteo enregistree dans meteo.json"
else
    #ecriture texte simple
    echo "$Date - $Heure - $Ville: $Temperature_actuelle°C - $Temperature_lendemain°C" >> meteo.txt
    echo "meteo enregistree dans meteo.txt"
fi

#nettoyage du fichier temporaire
rm meteo_temp.txt

