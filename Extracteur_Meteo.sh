#!/bin/bash



# Ville par défaut
Ville="Toulouse"
Json=false
TestError=false

# Gestion des arguments
for arg in "$@"; do
    case "$arg" in
        --json)
            Json=true
            ;;
        --test-error)
            TestError=true
            ;;
        *)
            # si ce n'est pas une option, c'est la ville
            Ville="$arg"
            ;;
    esac
done

# Date et heure
Date=$(date +"%Y-%m-%d")
Heure=$(date +"%H:%M")
FichierHistorique="meteo_${Date}.txt"
FichierTemp="meteo_temp.txt"
FichierLog="meteo_error.log"
FichierJson="meteo_${Date}_$(echo $Ville | tr ' ' '_').json"

# Récupération des données


if $TestError; then
    # Crée un fichier vide pour simuler une erreur
    > "$FichierTemp"
else
    curl -s "https://wttr.in/${Ville}?format=j1" > "$FichierTemp"
fi

# Gestion d'erreur si curl échoue ou fichier vide
if [ $? -ne 0 ] || [ ! -s "$FichierTemp" ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - ERREUR : Impossible de récupérer les données pour $Ville" >> "$FichierLog"
    echo "Erreur détectée ! Voir $FichierLog"
    exit 1
fi

# Vérifier si le JSON contient "temp_C" (ville valide)
if ! grep -q '"temp_C"' "$FichierTemp"; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - ERREUR : Données météo non valides pour $Ville" >> "$FichierLog"
    echo "Erreur détectée ! Voir $FichierLog"
    exit 1
fi

# Extraction des données

Temperature=$(grep '"temp_C"' "$FichierTemp" | head -1 | sed 's/[^0-9\-]//g')
Vent=$(grep '"windspeedKmph"' "$FichierTemp" | head -1 | sed 's/[^0-9]//g')
Humidite=$(grep '"humidity"' "$FichierTemp" | head -1 | sed 's/[^0-9]//g')
Visibilite=$(grep '"visibility"' "$FichierTemp" | head -1 | sed 's/[^0-9]//g')
Prevision=$(grep '"weatherDesc"' "$FichierTemp" | head -1 | sed 's/.*"value":"\([^"]*\)".*/\1/')

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

# =========================
# Nettoyage fichier temporaire
# =========================
rm -f "$FichierTemp"
