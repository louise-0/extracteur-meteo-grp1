#!/bin/bash


# Variante3 : Gestion des erreurs et logs


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
FichierHistorique="meteo.txt"
FichierTemp="meteo_temp.txt"
FichierLog="meteo_error.log"
FichierJson="meteo_${Date}_$(echo $Ville | tr ' ' '_').json"


# Récupération des données

curl -s "https://wttr.invalid/${Ville}?format=j1" > "$FichierTemp"


curl -s "https://wttr.in/${Ville}?format=j1" > "$FichierTemp"

# Vérifier si le JSON contient des données météo valides
if ! grep -q '"temp_C"[[:space:]]*:[[:space:]]*"[0-9\+\-]"' "$FichierTemp"; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - ERREUR : Données météo non valides pour $Ville" >> "$FichierLog"
    echo "Erreur détectée ! Voir $FichierLog"
    rm -f "$FichierTemp"
    exit 1
fi


# Gestion d'erreur si curl échoue ou fichier vide
if [ $? -ne 0 ] || [ ! -s "$FichierTemp" ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - ERREUR : Impossible de récupérer les données pour $Ville" >> "$FichierLog"
    echo "Erreur détectée ! Voir $FichierLog"
    exit 1
fi

# Vérifier si le JSON contient "temp_C" et "weatherDesc" (ville valide)
if ! grep -q '"temp_C"' "$FichierTemp"; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - ERREUR : Données météo non valides pour $Ville" >> "$FichierLog"
    echo "Erreur détectée ! Voir $FichierLog"
    rm -f "$FichierTemp"
    exit 1
fi


# Extraction des données

Temperature=$(grep '"temp_C"' "$FichierTemp" | head -1 | sed 's/[^0-9\-]//g')
# Sauvegarde

if $Json; then
    cat <<EOF > "$FichierJson"
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
    echo "Météo enregistrée dans $FichierJson"
else
    echo "$Date - $Heure - $Ville : $Temperature°C, $Prevision, Vent: ${Vent} km/h, Humidité: ${Humidite}%, Visibilité: ${Visibilite} km" >> "$FichierHistorique"
    echo "Météo enregistrée dans $FichierHistorique"
fi


# Nettoyage fichier temporaire


rm -f "$FichierTemp"
