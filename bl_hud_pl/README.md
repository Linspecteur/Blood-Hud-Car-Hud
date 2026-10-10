# BloodHUD Player (bl_hud_pl)

![FiveM](https://img.shields.io/badge/FiveM-Script-orange?style=flat-square)
![ESX](https://img.shields.io/badge/Framework-ESX-blue?style=flat-square)
![Licence](https://img.shields.io/badge/Licence-voir%20LICENSE-lightgrey?style=flat-square)

HUD joueur pour serveurs FiveM ESX : jauges de statut ancrées sur la minimap, infos joueur, boussole, indicateur vocal, HUD d'arme et bandeau d'annonces. Chaque module se déplace à la souris et se règle depuis un menu en jeu.

## Fonctionnalités

- **Jauges de statut** (vie, armure, faim, soif, endurance…) placées automatiquement au-dessus de la minimap, quelle que soit la résolution, le ratio (16:9, 21:9, 4:3) ou la safezone.
- **Mode édition** (`/hud`) : déplacement de chaque module par glisser-déposer, grille d'alignement, réinitialisation en un clic. La disposition est sauvegardée par joueur.
- **Disposition par défaut du serveur** : un admin enregistre sa disposition avec `/hudsavedefault`, elle s'applique aux nouveaux joueurs (`positions.json`).
- **Indicateur vocal** : portée (chuchoter / normal / crier), micro actif et fréquence radio. Compatible pma-voice, SaltyChat et mumble-voip.
- **HUD d'arme** : arme en main, chargeur et réserve, flash au tir, alerte chargeur vide. Masqué en véhicule, sauf en drive-by.
- **Bandeau d'annonces** : cartes rotatives (Discord, boutique, support, événement…), affichées en continu ou périodiquement, modifiables en jeu par les admins.
- **Mode cinéma** (`/cinema`) : masque le HUD et ajoute des bandes noires 21:9.
- **Masquage du HUD natif de GTA V** : argent, nom de rue, barres de vie/armure, endurance, arme. Chaque option est réglable.
- **Lien avec bl_hud_car** : le compteur de vitesse se déplace depuis le même menu.
- **Performance** : les boucles se mettent en veille quand rien ne change, sans `backdrop-filter` (qui fait saccader le navigateur de FiveM).

## Prérequis

- [es_extended](https://github.com/esx-framework/esx-legacy)
- Optionnel : [pma-voice](https://github.com/AvarianKnight/pma-voice), SaltyChat ou mumble-voip pour l'indicateur vocal

## Installation

1. Placer le dossier `bl_hud_pl` dans `resources/`.
2. Ajouter dans `server.cfg` :
   ```cfg
   ensure bl_hud_pl
   ```
3. Régler `config.lua` (commandes, jauges, système vocal, annonces, groupes admin).

## Commandes

| Commande | Rôle |
|---|---|
| `/hud` | Menu de personnalisation et mode déplacement |
| `/cinema` | Active / désactive le mode cinéma |
| `/hudsavedefault` | Enregistre la disposition actuelle comme défaut du serveur (admins, voir `Config.AdminGroups`) |
| `/hudweapon` | Affiche des infos de diagnostic du HUD d'arme dans la console F8 |

## Annonces

Les annonces se configurent dans `config.lua` (`Config.Announcements`) ou en jeu depuis l'onglet **Annonces** de `/hud`, réservé aux admins.

```lua
Config.Announcements = {
    enabled = true,
    interval = 8500, -- rotation toutes les 8,5 s
    display = { mode = 'periodic', showDuration = 20000, cycleInterval = 300000 },
    items = {
        { tag = "DISCORD", title = "REJOINS LA COMMUNAUTÉ", text = "discord.gg/tonserveur", icon = "fa-brands fa-discord", color = "#5865F2" },
        { tag = "SUPPORT", title = "BESOIN D'AIDE ?", text = "Tape /report en jeu", icon = "fa-solid fa-headset", color = "#00cec9" }
    }
}
```

## Exports

```lua
exports['bl_hud_pl']:SetHUDVisibility(true)   -- afficher / masquer le HUD
exports['bl_hud_pl']:ToggleHUD()              -- basculer la visibilité
exports['bl_hud_pl']:ToggleSettings(true)     -- ouvrir / fermer le menu /hud
exports['bl_hud_pl']:OpenSettings()           -- ouvrir le menu /hud
exports['bl_hud_pl']:ToggleCinematic(true)    -- mode cinéma
local hidden = exports['bl_hud_pl']:IsHUDHidden()
```

## Licence

Utilisation gratuite sur ton serveur, modifications autorisées pour ton usage. Revente, réupload et retrait des crédits interdits. Détails dans [LICENSE](LICENSE).

Développé par **BloodLeak**.
