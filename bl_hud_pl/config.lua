Config = {}

-- --- CONFIGURATION GÉNÉRALE DU HUD ---
Config.Debug = false


-- Fréquence de rafraîchissement des statuts (en millisecondes)
-- 250 ms suffit pour un affichage fluide
Config.TickRate = 250

-- --- TOUCHES & COMMANDES PAR DÉFAUT ---
-- Commande pour ouvrir le menu de personnalisation du HUD
Config.SettingsCommand = "hud"
Config.SettingsKey = nil -- Aucune touche par défaut (commande /hud uniquement)

-- Commande pour activer/désactiver le mode cinématique (bandes noires 21:9)
Config.CinematicCommand = "cinema"

-- --- ANCRAGE AUTOMATIQUE AU-DESSUS DE LA MINIMAP ---
-- Positionne automatiquement les jauges carrées au-dessus de la minimap GTA 5,
-- quelle que soit la résolution d'écran ou la safezone du joueur.
Config.MinimapAnchor = {
    enabled = true,
    gapY = 12,       -- Marge verticale (en pixels) entre le haut de la minimap et les carrés
    offsetX = 24     -- Décalage horizontal vers la droite (en pixels)
}

-- --- PARAMÈTRES DES JAUGES PAR DÉFAUT ---
Config.DefaultSettings = {
    -- Position des jauges : 'bottom-left', 'bottom-center', 'bottom-right'
    gaugesPosition = 'bottom-left',

    -- Échelle globale du HUD (entre 0.8 et 1.2)
    hudScale = 1.0,

    -- Visibilité par défaut des éléments
    showRpBar = true,          -- Barre info RP en haut à droite
    showMoney = true,          -- Affichage du cash
    showBank = true,           -- Affichage de la banque
    showDirtyMoney = true,     -- Affichage de l'argent sale (masqué si 0$)
    showCompass = true,        -- Boussole et nom de rue
    showJob = true,            -- Métier & grade
    showGang = true,           -- Gang / Organisation secondaire
    showId = true,             -- ID du joueur
    showPlayersCount = true,   -- Nombre de joueurs connectés
    showWeather = true,        -- Cercle météo et température sous la date

    -- Visibilité des jauges de statut
    showHealth = true,         -- Jauge de vie
    showArmor = true,          -- Jauge d'armure / gilet
    hideArmorWhenEmpty = true, -- Masquer l'armure si elle est à 0%
    showHunger = true,         -- Jauge de faim
    showThirst = true,         -- Jauge de soif
    showStamina = true,        -- Jauge d'endurance / sprint
    showOxygen = true,         -- Jauge d'oxygène (plongée)
    showStress = false,        -- Jauge de stress (activable si votre serveur gère le stress)
    showVoice = true,          -- Jauge et statut du micro
    showWeapon = true          -- HUD d'arme & munitions en bas à droite
}

-- Désactiver le HUD d'arme par défaut de GTA 5 (icône blanche et munitions en haut à droite)
Config.HideDefaultWeaponHud = true

-- --- GESTION DU HUD D'ARME EN VÉHICULE ---
-- Masquer le HUD d'arme lorsque le joueur est dans un véhicule (évite l'apparition au volant)
Config.HideWeaponInVehicle = true

-- Afficher le HUD d'arme en véhicule uniquement lorsqu'il vise / tire (Drive-by)
Config.ShowWeaponOnlyOnDriveby = true

-- Désactiver les affichages d'argent natifs de GTA 5 ($ en haut à droite)
Config.HideDefaultCashHud = true

-- Désactiver les noms de rues & véhicules natifs de GTA 5 (au-dessus de la minimap)
Config.HideDefaultStreetName = true

-- Désactiver la barre d'endurance / capacité spéciale native de GTA V sous la minimap
Config.HideDefaultStaminaBar = true

-- Désactiver les barres de vie et d'armure natives de GTA V sous la minimap (barre verte & bleue)
Config.HideRadarHealthArmour = true

-- --- SEUILS CRITIQUES D'ALERTES ---
-- En dessous de ces valeurs, la jauge pulse en alerte visuelle
Config.CriticalThresholds = {
    health = 25,  -- Alerte de santé faible (< 25%)
    hunger = 20,  -- Alerte de faim (< 20%)
    thirst = 20,  -- Alerte de soif (< 20%)
    oxygen = 25,  -- Alerte manque d'oxygène (< 25%)
    stress = 75   -- Alerte stress élevé (> 75%)
}

-- --- PERTE DE VIE QUAND LA FAIM / LA SOIF ATTEIGNENT 0% ---
Config.Starvation = {
    enabled = false,      -- Mettre à true pour activer la perte de vie
    interval = 5000,      -- Délai entre deux pertes de vie (ms)
    affectHunger = true,  -- Perte de vie quand la faim est à 0%
    affectThirst = true,  -- Perte de vie quand la soif est à 0%
    hungerDamage = 3,     -- PV retirés par intervalle (faim à 0%)
    thirstDamage = 4,     -- PV retirés par intervalle (soif à 0%)
    screenEffect = true   -- Légère secousse de caméra à chaque perte
}

-- --- COMPTES & ÉCONOMIE (ESX / COMPATIBILITÉ) ---
Config.Accounts = {
    cash = 'money',             -- Nom du compte cash dans ESX
    bank = 'bank',              -- Nom du compte banque dans ESX
    black_money = 'black_money' -- Nom du compte argent sale dans ESX
}

-- Format de devise ($ 1,500 ou 1 500 $)
Config.CurrencySymbol = "$"
Config.CurrencyPosition = "prefix" -- 'prefix' ($100) ou 'suffix' (100$)

-- --- SYSTÈMES VOCAUX SUPPORTÉS ---
-- 'pma-voice', 'saltychat', 'mumble-voip' ou 'native'
Config.VoiceSystem = 'pma-voice'

-- Niveaux de distance vocale par défaut (en mètres) et labels
Config.VoiceRanges = {
    [1] = { label = "Chuchoter", distance = 1.5, percentage = 33 },
    [2] = { label = "Normal",    distance = 3.0, percentage = 66 },
    [3] = { label = "Crier",     distance = 8.0, percentage = 100 }
}

-- --- PERMISSIONS POUR SAUVEGARDER PAR DÉFAUT SERVEUR ---
Config.AdminGroups = {
    ["boss"] = true,
    ["admin"] = true,
    ["superadmin"] = true,
    ["founder"] = true,
    ["fondateur"] = true,
    ["owner"] = true,
    ["_dev"] = true,
    ["mod"] = true,
    ["moderator"] = true
}

-- Autoriser également si le grade du métier ou de l'organisation est 'boss'
Config.AllowBossGrade = true

-- Autoriser tout le monde sans vérification (désactivé par défaut)
Config.AllowEveryoneToSetServerDefault = false

-- --- BANDEAU D'ANNONCES & PUB DYNAMIQUE (CARROUSEL) ---
Config.Announcements = {
    enabled = true,
    interval = 8500, -- Intervalle de défilement (en millisecondes)

    -- Affichage de la carte (ne s'enregistre pas depuis /hud, uniquement ici)
    display = {
        mode = 'periodic',      -- 'periodic' (apparitions régulières) ou 'always' (toujours affichée)
        showDuration = 20000,   -- Durée d'apparition en mode 'periodic' (ms)
        cycleInterval = 300000, -- Une apparition toutes les X ms (300000 = 5 minutes)
        hideInVehicle = true,   -- Masquer dans un véhicule
        hideWhenAiming = true,  -- Masquer quand le joueur vise
        hideInCinematic = true  -- Masquer en mode cinéma (/cinema)
    },

    items = {
        {
            icon = "fa-brands fa-discord",
            tag = "DISCORD",
            title = "REJOINS LA COMMUNAUTÉ",
            text = "discord.gg/bloodleak",
            color = "#5865F2",
            cta = "REJOINDRE"
        },
        {
            icon = "fa-solid fa-cart-shopping",
            tag = "BOUTIQUE",
            title = "OFFRES VIP & VÉHICULES",
            text = "shop.bloodleak.fr",
            color = "#FF2A2A",
            cta = "VISITER"
        },
        {
            icon = "fa-solid fa-headset",
            tag = "SUPPORT",
            title = "BESOIN D'ASSISTANCE ?",
            text = "Tapez /report en jeu",
            color = "#00E5FF",
            cta = "CONTACT"
        },
        {
            icon = "fa-solid fa-trophy",
            tag = "EVENT",
            title = "TOURNOI CE SOIR À 21H",
            text = "Gros cashprize & surprises !",
            color = "#FFB800",
            cta = "INFOS"
        }
    }
}

