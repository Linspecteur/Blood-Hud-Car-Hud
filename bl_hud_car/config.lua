Config = {}

-- --- CONFIGURATION GÉNÉRALE DU SPEEDOMETER ---
Config.Debug = false


-- Unité de vitesse : 'KMH' ou 'MPH'
Config.SpeedUnit = 'KMH'

-- Échelle globale du Speedometer (1.1 = lisible & équilibré, 1.0 = standard, 1.25 = grand)
Config.HudScale = 1.1

-- Activation de la rampe de Shift-Lights LED (style GT3 / Supercar)
Config.ShowShiftLights = true

-- Fréquence de rafraîchissement en véhicule (en ms)
Config.RefreshRate = 50

-- --- MASQUAGE DU HUD NATIF GTA V EN VÉHICULE ---
-- Désactive l'icône d'arme et munitions natives de GTA V en haut à droite en véhicule
Config.HideDefaultWeaponHud = true

-- Désactive l'affichage natif du nom du véhicule et de la rue au-dessus de la minimap
Config.HideDefaultVehicleName = true

-- --- CEINTURE DE SÉCURITÉ & CRASH ÉJECTION ---
Config.EnableSeatbelt = true
Config.SeatbeltKey = "B" -- Touche pour attacher/détacher la ceinture
Config.SeatbeltCommand = "seatbelt"

-- Éjection du pare-brise si accident sans ceinture (vitesse mini en KM/H)
Config.EjectOnCrash = true
Config.EjectionSpeed = 70.0 -- Vitesse minimale d'impact pour être éjecté

-- Sons de la ceinture (Web Audio API synthétique)
Config.PlaySeatbeltSound = true

-- --- MODE CROISIÈRE & RÉGULATEUR DE VITESSE (CRUISE CONTROL) ---
Config.EnableCruiseControl = true
Config.CruiseControlKey = "Y" -- Touche pour activer/désactiver le régulateur
Config.CruiseControlCommand = "cruise"
Config.CruiseMinSpeed = 20.0 -- Vitesse minimale en KM/H pour activer le régulateur
Config.CruiseAutoThrottle = true -- Maintient la vitesse automatiquement sans appuyer sur l'accélérateur
Config.CruiseSpeedStep = 5 -- Palier d'ajustement en KM/H (/cruise + ou /cruise -)

-- --- CLIGNOTANTS & FEUX DE DÉTRESSE (TURN SIGNALS) ---
Config.EnableBlinkers = true
Config.BlinkerLeftKey = "LEFT"   -- Touche Clignotant Gauche (Flèche Gauche)
Config.BlinkerRightKey = "RIGHT" -- Touche Clignotant Droit (Flèche Droite)
Config.BlinkerWarnKey = "DOWN"   -- Touche Feux de Détresse / Warning (Flèche Bas)
Config.PlayBlinkerSound = true   -- Son synthétique de relais de clignotant

-- --- GESTION DU CARBURANT (FUEL) ---
-- 'auto', 'ox_fuel', 'LegacyFuel', 'ps-fuel', 'cdn-fuel', 'native'
Config.FuelScript = 'auto'

-- Seuil d'alerte carburant faible (en %)
Config.LowFuelThreshold = 20

-- Seuil d'alerte moteur endommagé (en %)
Config.EngineDamageThreshold = 40

-- Seuil d'alerte carrosserie/châssis endommagé (en %)
Config.BodyDamageThreshold = 40

-- --- MODULES DU COCKPIT ---
-- Affichage du nom et de la marque du véhicule en direct
Config.ShowVehicleHeader = true

-- Sélecteur de mode de conduite dynamique (CONFORT / SPORT / CIRCUIT / DRIFT)
Config.ShowDriveModes = true

-- Jauge de pression Turbo dynamique (-1.0 à +2.0 BAR avec dépression et boost)
Config.ShowTurbo = true
Config.TurboUnit = 'BAR' -- 'BAR' ou 'PSI'

-- Accéléromètre G-Force temps réel 2D (forces latérales & longitudinales avec Friction Circle)
Config.ShowGMeter = true

-- Affichage de la température moteur (°C / optimale 90°C)
Config.ShowEngineTemp = true

-- Système de sécurité active (ABS au freinage, TC/ESP au patinage, TPMS crevaison)
Config.ShowSafetyAssists = true

-- Odomètre numérique (Kilométrage total ODO & journalier TRIP)
Config.ShowOdometer = true

-- Calcul de l'autonomie restante estimée (RANGE en KM)
Config.ShowFuelRange = true

-- --- AUTO-CONDUITE VIP / STAFF (AUTOPILOTE) ---
Config.EnableAutoDrive = true

-- Touche pour activer/désactiver l'auto-pilote
Config.AutoDriveKey = "G"

-- Vitesse maximale de l'auto-pilote en KM/H (80 = ville, 120 = voie rapide)
Config.AutoDriveSpeed = 80.0

-- Style de conduite de l'IA (1 = prudent, 4 = normal, 7 = sportif, 10 = agressif)
Config.AutoDriveStyle = 786603  -- Flags : respecte la circulation, évite les véhicules, freine aux feux

-- Grades autorisés à utiliser l'auto-conduite (bl_admin_v3 / bl_admin / ESX)
Config.AutoDriveAllowedGrades = {
    'boss', 'owner', 'fondateur', 'manager', 'superviseur',
    'superadmin', 'admin', 'moderateur', 'mod', 'animateur',
    'helper', 'vip', 'staff'
}

-- Activer l'auto-conduite pour TOUS les joueurs (ignorer la vérification de grade)
-- Mettre à true pour tester ou pour un serveur sans système de grades
Config.AutoDrivePublic = false

-- Distance d'arrêt automatique à la destination (en mètres)
Config.AutoDriveStopRadius = 12.0

-- Message de notification d'accès refusé (affiché dans le toast bl_admin_v3)
Config.AutoDriveAccessDeniedMsg = "L'auto-conduite autonome est réservée aux membres VIP et Staff."

-- Message si aucun repère GPS n'a été placé sur la carte
Config.AutoDriveNoWaypointMsg = "Veuillez d'abord placer un repère GPS sur votre carte pour activer l'auto-conduite."

-- --- PERSONNALISATION DE L'EMPLACEMENT DU SPEEDOMETER ---
Config.EnablePositionCustomization = true
Config.CarHudEditCommand = "carhud" -- Commande directe pour déplacer le HUD véhicule (ou via /hud)

