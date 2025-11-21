#!/bin/bash

# Ville par défaut
Ville="Toulouse"
Json=false

# Gestion des arguments
if [ "$1" == "--json" ]; then
    Json=true
elif [ -n "$1" ]; then
    Ville="$1"
    if [ "$2" == "--json" ]; then
        Json=true
    fi
fi

# Date et heure
Date=$(date +"%Y-%m-%d")
Heure=$(date +"%H:%M")
FichierHistorique="meteo_${Date}.txt"
FichierTemp="meteo_temp.txt"
FichierLog="meteo_error.log"

# Récupération des données
curl -s "https://wttr.invalid/${Ville}?format=j1" > "$FichierTemp"

# Gestion d'erreur si curl échoue ou fichier vide
if [ $? -ne 0 ] || [ ! -s "$FichierTemp" ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - ERREUR : Impossible de récupérer les données pour $Ville" >> "$FichierLog"
    exit 1
fi

# Extraction des données
Temperature=$(grep '"temp_C"' "$FichierTemp" | head -1 | sed 's/[^0-9\-]//g')
Vent=$(grep '"windspeedKmph"' "$FichierTemp" | head -1 | sed 's/[^0-9]//g')
Humidite=$(grep '"humidity"' "$FichierTemp" | head -1 | sed 's/[^0-9]//g')
Visibilite=$(grep '"visibility"' "$FichierTemp" | head -1 | sed 's/[^0-9]//g')
Prevision=$(grep -oP '"weatherDesc"\s*:\s*\[{"value":"\K[^"]+' "$FichierTemp" | head -1)

# Valeur par défaut si vide
[ -z "$Temperature" ] && Temperature="ND"
[ -z "$Vent" ] && Vent="ND"
[ -z "$Humidite" ] && Humidite="ND"
[ -z "$Visibilite" ] && Visibilite="ND"
[ -z "$Prevision" ] && Prevision="ND"

# Affichage
echo "$Date - $Heure - $Ville : $Temperature°C, $Prevision, Vent: ${Vent} km/h, Humidité: ${Humidite}%, Visibilité: ${Visibilite} km"

# Sauvegarde
if $Json; then
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
    echo "Météo enregistrée dans meteo.json"
else
    echo "$Date - $Heure - $Ville : $Temperature°C, $Prevision, Vent: ${Vent} km/h, Humidité: ${Humidite}%, Visibilité: ${Visibilite} km" >> "$FichierHistorique"
    echo "Météo enregistrée dans $FichierHistorique"
fi

# Nettoyage fichier temporaire
rm "$FichierTemp"
