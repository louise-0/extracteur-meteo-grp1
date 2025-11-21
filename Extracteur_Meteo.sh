#!/bin/bash

#Toulouse par defaut si aucun argument
Ville="Toulouse"

#option de sauvegarde json 
Json=false
if [ "$1" == "--json" ]; #le premier argument est --json on active la sauvegarde en json
then
    Json=true
elif [ -n "$1" ]; #si un premier argument existe il est pris comme ville
then
    Ville="$1" #un deuxieme argument est present
    if [ "$2" == "--json" ]; 
then  #l'option de sauvegarde en json sactive
        Json=true
    fi
fi

Date=$(date +"%Y-%m-%d")
Heure=$(date +"%H:%M")

#recuperation des donnes meterologique et les stocker dans fichier temp
curl -s "https://wttr.in/${Ville}?format=j1" > meteo_temp.txt

#grep -m recupere la 1ere occurence
#sed s/[^0-9\-]//g supprime tout sauf les chiffres et signe -
#extraction des donnees actuelles
Temperature=$(grep '"temp_C"' meteo_temp.txt | head -1 | sed 's/[^0-9\-]//g')
Vent=$(grep '"windspeedKmph"' meteo_temp.txt | head -1 | sed 's/[^0-9]//g')
Humidite=$(grep '"humidity"' meteo_temp.txt | head -1 | sed 's/[^0-9]//g')
Visibilite=$(grep '"visibility"' meteo_temp.txt | head -1 | sed 's/[^0-9]//g')
Prevision=$(grep -oP '"weatherDesc"\s*:\s*\[{"value":"\K[^"]+' meteo_temp.txt | head -1)

# Valeur par défaut si vide
[ -z "$Prevision" ] && Prevision="ND"

# Valeurs par defaut si donnees manquantes
[ -z "$Temperature" ] && Temperature="ND"
[ -z "$Vent" ] && Vent="ND"
[ -z "$Humidite" ] && Humidite="ND"
[ -z "$Visibilite" ] && Visibilite="ND"
[ -z "$Prevision" ] && Prevision="ND"SS

#sauvegarde
if $Json; 
then
    cat <<EOF > meteo.json
{
  "date": "$Date",
  "heure": "$Heure",
  "ville": "$Ville",
  "temperature": "${Temperature}°C",
  "prevision": "$Prevision",
  "vent": "${Vent} km/h",
  "humidite": "${Humidite}%",
  "visibilite": "${Visibilite} km"
}
EOF

    echo "Meteo enregistree dans meteo.json"
else
    echo "$Date - $Heure - $Ville : $Temperature°C, $Prevision, Vent: ${Vent} km/h, Humidité: ${Humidite}%, Visibilité: ${Visibilite} km" >> meteo.txt
    echo "Météo enregistrée dans meteo.txt"
fi

#nettoyage fichier temporaire
rm meteo_temp.txt
