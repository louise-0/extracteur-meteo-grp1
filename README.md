Configuration du cron :

 - Un workflow GitHub Actions a été mis en place sur la branche main.
 - Ce workflow utilise la branche Version2 comme référence.
 - Une planification cron a été ajoutée pour lancer automatiquement le script toutes les 24 heures.
 - Le script Extracteur_meteo.sh reçoit les droits d’exécution nécessaires.
 - Le fichier meteo.txt se voit attribuer les permissions d’écriture pour pouvoir être mis à jour.
 - Le workflow s’occupe ensuite de s’authentifier, puis de faire le commit et le push du script.
 - Une vérification est effectuée pour confirmer que le fichier meteo.txt est bien présent et correctement mis à jour dans le dépôt.

Tentative avec WSL (non retenue) :
Une configuration via WSL a été testée, mais abandonnée pour plusieurs raisons :

  - Chaque utilisateur devait maintenir sa propre arborescence locale, ce qui compliquait le travail en groupe.
  - L’authentification GitHub posait régulièrement problème.
  - Les actions de commit et de push vers GitHub ne fonctionnaient pas correctement.

