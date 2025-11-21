#!/bin/bash

ville_par_defaut="Toulouse" #si l'utlisateur fourni aucune ville comme argument
ville="" #stocker la ville fournie par l'utlisateur
option="" #pour contenir l'optiin --archive

if [ "$1" == "--archive" ]; #l'utilisateur a passe l’option --archive avant la ville
then
    option="--archive" #memoriser l'option
    ville="$2"  #la ville sera le 2eme argument dans la commande
else   #pas d’option --archive
    ville="$1"  #le premier argument est la vile
    option="$2" #le 2eme argument sera l'option elle peut rester vide 
fi

if [ -z "$ville" ]; #teste avec -z si la variable est vide
then
    ville=$ville_par_defaut  #si cest le cas Toulouse sera comme argument
fi

temp_fichier_txt="meteo_temp.txt" #sert a stocker la reponse brute de wttr.in
fichier_sortie="meteo.txt" #le fichier finale ou la meteo sera enregistree

if [ "$option" == "--archive" ]; #l'option est active
then
    date_actuelle=$(date +"%Y%m%d")   #recuperer la date sous format AAAAMMJJ
    fichier_sortie="meteo_${date_actuelle}.txt" #renommer le fichier finale a la date correspondante du jour
fi

curl -s "wttr.in/${ville}?format=3" -o "$temp_fichier_txt"
#enregister la meteo dans le fichier temp
#?format=3 cest un format court qui affiche la ville +meteo

temp_actuelle=$(cut -d':' -f2 "$temp_fichier_txt" | xargs) #xargs supprime les espaces inutiles
#cut -d':' -f2 coupe la ligne au caractere : et prend la 2eme partie

curl -s "https://wttr.in/${ville}?format=j1" -o "$donnees_meteoVille"

# Récupère les températures dans le fichier des donnees meteos
tempActuelle=$(grep -m1 '"temp_C"' "$donnees_meteoVille" | sed 's/[^0-9\-]//g')
tempDemain=$(grep -m1 '"avgtempC"' "$donnees_meteoVille" | sed 's/[^0-9\-]//g')
# Récupère le taux d'humidité, la vitesse du vent et la visibilité
humidite=$(grep -m1 '"humidity"' "$donnees_meteoVille" | sed 's/[^0-9]//g')
vent=$(grep -m1 '"windspeedKmph"' "$donnees_meteoVille" | sed 's/[^0-9]//g')
visibilite=$(grep -m1 '"visibility"' "$donnees_meteoVille" | sed 's/[^0-9]//g')

if [ -z "$tempActuelle" ]; then
    tempActuelle="N/A"
    exit 3
fi

temp_actuelle=$(cut -d':' -f2 "$temp_fichier_txt" | xargs) #xargs supprime les espaces inutiles
#cut -d':' -f2 coupe la ligne au caractere : et prend la 2eme partie

date_du_jour=$(date +"%Y-%m-%d")
heure_actuelle=$(date +"%H:%M")

ligne="${date_du_jour} - ${heure_actuelle} - ${ville} : ${temp_actuelle} " #affichage avce format demande

echo "$ligne" >> "$fichier_sortie"

rm "$temp_fichier_txt"

echo "$ligne"

jour=$(date +"%Y-%m-%d")
heure=$(date +"%H:%M")

echo "${jour} - ${heure} - ${ville} : ${tempActuelle}°C - ${tempDemain}°C - Vitesse du vent : ${vent}km/h - Taux d'humidité : ${humidite}% - Visibilité : ${visibilite}km" >> meteo.txt
echo "Les données météorologiques de ${ville} ont été formatées et enregistrées dans meteo.txt."
