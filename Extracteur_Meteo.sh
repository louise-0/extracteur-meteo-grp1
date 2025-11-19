#!/bin/bash

# Verifie si un argument est fourni, sinon Toulouse comme valeur par défaut 
if [ "$1" = "" ]; then
    ville="Toulouse"
    echo "Aucune ville spécifiée. Utilisation de la ville par défaut : ${ville}"
else
    ville=$1
fi


# Selectionne la date et heure actuelle
date=$(date  +"%Y-%m-%d %H:%M:%S")

# Cree un fichier pour les donnees meteorologiques de la ville choisie
donnees_meteoVille="meteo_ville.txt"
curl -s "https://wttr.in/${ville}?format=j1" >"$donnees_meteoVille"

if [ "$donnees_meteoVille" = "" ];
then
    echo "Erreur! Impossible de recuperer la meteo"
    exit 2
fi

# Récupère les températures dans le fichier des donnees meteos
tempActuelle=$(grep -m1 '"temp_C"' "$donnees_meteoVille" | sed 's/[^0-9\-]//g')
tempDemain=$(grep -m1 '"avgtempC"' "$donnees_meteoVille" | sed 's/[^0-9\-]//g')

humidite=$(grep -m1 '"humidity"' "$donnees_meteoVille" | sed 's/[^0-9]//g')
vent=$(grep -m1 '"windspeedKmph"' "$donnees_meteoVille" | sed 's/[^0-9]//g')
visibilite=$(grep -m1 '"visibility"' "$donnees_meteoVille" | sed 's/[^0-9]//g')

if [ -z "$tempActuelle" ]; then
    tempActuelle="N/A"
    exit 3
fi

if [ -z "$tempDemain" ]; then
    tempDemain="N/A"
    exit 4
fi

jour=$(date +"%Y-%m-%d")
heure=$(date +"%H:%M")
echo "${jour} - ${heure} - ${ville} : ${tempActuelle}°C - ${tempDemain}°C ; Humidite : ${humidite}% ; Vent : ${vent}km/h ; Visibilite : ${visibilite}km" >> meteo.txt
echo "Les données météorologiques de ${ville} ont été formatées et enregistrées dans meteo.txt."
