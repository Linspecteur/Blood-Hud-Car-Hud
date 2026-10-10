# BloodHUD

![FiveM](https://img.shields.io/badge/FiveM-Script-orange?style=flat-square)
![ESX](https://img.shields.io/badge/ESX-compatible-blue?style=flat-square)
![Licence](https://img.shields.io/badge/Licence-voir%20LICENSE-lightgrey?style=flat-square)

HUD joueur et compteur de vitesse pour serveurs FiveM, développés par **BloodLeak**.
Deux ressources indépendantes, pensées pour fonctionner ensemble : un seul menu `/hud` règle les deux.

## Contenu du dépôt

| Ressource | Rôle | Documentation |
|---|---|---|
| [`bl_hud_pl`](bl_hud_pl) | HUD joueur : jauges de statut, infos joueur, boussole, indicateur vocal, HUD d'arme, bandeau d'annonces, mode cinéma | [README](bl_hud_pl/README.md) |
| [`bl_hud_car`](bl_hud_car) | Compteur de vitesse : shift lights, télémétrie, régulateur et limiteur, ceinture avec éjection, clignotants, conduite automatique | [README](bl_hud_car/README.md) |

Tu peux installer les deux, ou seulement celle dont tu as besoin.

## Points forts

- **Tout se déplace à la souris** : chaque module du HUD joueur et le compteur. La disposition est sauvegardée par joueur, et un admin peut définir celle des nouveaux joueurs.
- **Ancrage automatique sur la minimap** : les jauges restent au-dessus du radar, quelle que soit la résolution ou le ratio (16:9, 21:9, 4:3).
- **Compteur façon GT3** : rampe de shift lights, turbo, G-mètre, modes de conduite, régulateur et limiteur.
- **Compatible avec les ressources courantes** : pma-voice pour le vocal (micro, portée, radio) ; ox_fuel, LegacyFuel, ps-fuel, cdn-fuel pour le carburant.
- **Léger** : boucles en veille quand rien ne change, pas de `backdrop-filter` (qui fait saccader le navigateur de FiveM).

## Installation

1. Télécharger le dépôt : bouton **Code** puis **Download ZIP**.
2. Copier les dossiers `bl_hud_pl` et `bl_hud_car` dans `resources/`.
   Si tu copies le dossier extrait en entier, renomme-le entre crochets (par exemple `[bloodhud]`), sinon FiveM ne trouvera pas les ressources.
3. Ajouter dans `server.cfg` :
   ```cfg
   ensure bl_hud_pl
   ensure bl_hud_car
   ```
4. Optionnel, donner les droits admin :
   ```cfg
   # Disposition par défaut et annonces du HUD joueur
   add_ace group.admin hud.admin allow
   # Conduite automatique du compteur
   add_ace group.admin bl_hud_car.autopilote allow
   ```
5. Régler le `config.lua` de chaque ressource.

## Prérequis

| | bl_hud_pl | bl_hud_car |
|---|---|---|
| Framework | [es_extended](https://github.com/esx-framework/esx-legacy) recommandé | Aucun (ESX optionnel, pour réserver la conduite automatique à certains groupes) |
| Vocal | [pma-voice](https://github.com/AvarianKnight/pma-voice) (optionnel) : micro, portée et radio. Avec une autre voix basée sur Mumble, seul le micro actif s'affiche | — |
| Carburant | — | ox_fuel, LegacyFuel, ps-fuel ou cdn-fuel (détection automatique, sinon carburant natif) |

## Commandes principales

| Commande | Ressource | Rôle |
|---|---|---|
| `/hud` | bl_hud_pl | Menu de personnalisation et mode déplacement (les deux HUD) |
| `/cinema` | bl_hud_pl | Mode cinéma |
| `/hudsavedefault` | bl_hud_pl | Enregistre la disposition par défaut du serveur (admins) |
| `/carhud` | bl_hud_car | Déplacer le compteur |
| `/autopilote` | bl_hud_car | Conduite automatique vers le point GPS |

Liste complète des touches, commandes et exports dans le README de chaque ressource.

## Structure

```
.
├── bl_hud_pl/     HUD joueur
├── bl_hud_car/    Compteur de vitesse
├── LICENSE
└── README.md
```

## Licence

Utilisation gratuite sur ton serveur, modifications autorisées pour ton usage. Revente, réupload et retrait des crédits interdits. Détails dans [LICENSE](LICENSE).

## Crédits

- Développement : **BloodLeak**
- Polices : [Google Fonts](https://fonts.google.com) (licence SIL Open Font)
- Icônes : [Font Awesome Free](https://fontawesome.com) (licence CC BY 4.0)

Un bug ou une idée ? Ouvre une issue sur ce dépôt.
Shell cwd was reset to c:\Users\natha\Desktop\BloodLeak v2\[JOB INTERIME]\bl_amazon
