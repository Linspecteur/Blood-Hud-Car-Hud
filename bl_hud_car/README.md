# BloodHUD Car (bl_hud_car)

![FiveM](https://img.shields.io/badge/FiveM-Script-orange?style=flat-square)
![ESX](https://img.shields.io/badge/Framework-ESX-blue?style=flat-square)
![Licence](https://img.shields.io/badge/Licence-voir%20LICENSE-lightgrey?style=flat-square)

Compteur de vitesse inspiré des tableaux de bord de GT3 pour FiveM : shift lights, télémétrie, régulateur et limiteur, ceinture avec éjection, clignotants et conduite automatique vers le point GPS.

## Fonctionnalités

- **Shift lights** : rampe de LEDs (vert, ambre, rouge) calée sur le régime moteur et le rupteur.
- **Télémétrie** : vitesse, régime, rapport, turbo (BAR ou PSI), carburant et autonomie, état du moteur et de la carrosserie, température moteur, G-mètre, odomètre ODO / TRIP.
- **Assistances** : témoins ABS, antipatinage et crevaison.
- **Modes de conduite** : confort, sport, circuit, croisière, drift.
- **Régulateur et limiteur de vitesse** : activation en une touche, réglage par paliers de 5 km/h, coupure au freinage.
- **Ceinture de sécurité** : son au bouclage, témoin, éjection par le pare-brise en cas de choc violent sans ceinture (vitesse réglable).
- **Clignotants et warnings** : arrêt automatique du clignotant après le virage.
- **Conduite automatique** (`/autopilote`) : le véhicule rejoint le point GPS en respectant la circulation et les feux. Réservée à certains grades par défaut.
- **Position libre** (`/carhud`) : le compteur se déplace à la souris, la position est sauvegardée.
- **Carburant** : détection automatique d'ox_fuel, LegacyFuel, ps-fuel et cdn-fuel, sinon carburant natif.
- **Performance** : rendu SVG léger, boucles en veille quand le joueur est à pied.

## Prérequis

- [es_extended](https://github.com/esx-framework/esx-legacy)
- Recommandé : [bl_hud_pl](../bl_hud_pl) pour régler le compteur depuis le menu `/hud`

## Installation

1. Placer le dossier `bl_hud_car` dans `resources/`.
2. Ajouter dans `server.cfg` :
   ```cfg
   ensure bl_hud_car
   ```
3. Régler `config.lua` (unité KMH / MPH, touches, éjection, régulateur, conduite automatique).

### Accès à la conduite automatique

Les grades autorisés sont listés dans `Config.AutoDriveAllowedGrades`. Le grade est lu depuis le groupe ESX du joueur, ou depuis `bl_admin` / `bl_admin_v3` s'ils sont installés (ressources propres au serveur BloodLeak, non fournies). Pour ouvrir la fonction à tout le monde : `Config.AutoDrivePublic = true`.

## Touches et commandes

| Touche | Commande | Rôle |
|---|---|---|
| `B` | `/seatbelt`, `/ceinture` | Attacher / détacher la ceinture |
| `Y` | `/cruise`, `/regulateur` | Activer / couper le régulateur |
| `Page ↑` / `Page ↓` | | Vitesse du régulateur +5 / −5 km/h |
| | `/limiteur [vitesse]` | Limiteur de vitesse |
| | `/mode [confort\|sport\|circuit\|croisiere\|drift\|auto]` | Mode de conduite |
| `←` / `→` | `/clignotant` | Clignotant gauche / droit |
| `↓` | `/warning` | Feux de détresse |
| `G` | `/autopilote`, `/autopilote_stop` | Conduite automatique vers le point GPS |
| | `/carhud` | Déplacer le compteur |

Les touches se changent dans `config.lua` ou dans les paramètres de touches FiveM du joueur.

## Exports

```lua
exports['bl_hud_car']:ToggleSeatbelt()
local belted = exports['bl_hud_car']:IsSeatbeltOn()
exports['bl_hud_car']:StartEditMode()
exports['bl_hud_car']:ToggleCruise()
```

## Licence

Utilisation gratuite sur ton serveur, modifications autorisées pour ton usage. Revente, réupload et retrait des crédits interdits. Détails dans [LICENSE](LICENSE).

Développé par **BloodLeak**.
