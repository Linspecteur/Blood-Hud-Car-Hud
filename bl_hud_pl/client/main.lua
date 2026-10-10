local lastPauseMenuState = false
local lastHealth = -1
local lastArmor = -1
local lastOxygen = -1
local lastStamina = -1
local lastTalking = false
local lastStreet = ""
local lastZone = ""
local lastHeading = ""
local lastInVehicle = false
local lastAiming = false
local lastWeaponHash = false
local lastAmmoClip = -1
local lastAmmoTotal = -1
local lastLowAmmo = false
local lastSilenced = false
local lastFlashlight = false

-- Table de secours des noms d'armes GTA V pour un affichage propre
local WeaponLabels = {
    -- Pistolets
    [`WEAPON_PISTOL`] = "Pistolet",
    [`WEAPON_PISTOL_MK2`] = "Pistolet Mk II",
    [`WEAPON_COMBATPISTOL`] = "Pistolet de Combat",
    [`WEAPON_APPISTOL`] = "Pistolet AP",
    [`WEAPON_PISTOL50`] = "Pistolet .50",
    [`WEAPON_SNSPISTOL`] = "Pétoire",
    [`WEAPON_SNSPISTOL_MK2`] = "Pétoire Mk II",
    [`WEAPON_HEAVYPISTOL`] = "Pistolet Lourd",
    [`WEAPON_VINTAGEPISTOL`] = "Pistolet Vintage",
    [`WEAPON_FLAREGUN`] = "Pistolet de Détresse",
    [`WEAPON_MARKSMANPISTOL`] = "Pistolet Marksman",
    [`WEAPON_REVOLVER`] = "Revolver Lourd",
    [`WEAPON_REVOLVER_MK2`] = "Revolver Mk II",
    [`WEAPON_DOUBLEACTION`] = "Revolver Double Action",
    [`WEAPON_CERAMICPISTOL`] = "Pistolet Céramique",
    [`WEAPON_NAVYREVOLVER`] = "Revolver Navy",
    [`WEAPON_GADGETPISTOL`] = "Pistolet Perico",
    [`WEAPON_STUNGUN`] = "Taser paralysant",
    [`WEAPON_RAYPISTOL`] = "Up-n-Atomizer",

    -- Mitraillettes & SMG
    [`WEAPON_MICROSMG`] = "Micro SMG",
    [`WEAPON_SMG`] = "Mitraillette SMG",
    [`WEAPON_SMG_MK2`] = "SMG Mk II",
    [`WEAPON_ASSAULTSMG`] = "SMG d'Assaut",
    [`WEAPON_COMBATPDW`] = "Combat PDW",
    [`WEAPON_MACHINEPISTOL`] = "Machine Pistol",
    [`WEAPON_MINISMG`] = "Mini SMG",
    [`WEAPON_RAYCARBINE`] = "Dézinguateur Infernal",

    -- Fusils à pompe
    [`WEAPON_PUMPSHOTGUN`] = "Fusil à Pompe",
    [`WEAPON_PUMPSHOTGUN_MK2`] = "Fusil à Pompe Mk II",
    [`WEAPON_SAWNOFFSHOTGUN`] = "Fusil à Canon Scié",
    [`WEAPON_ASSAULTSHOTGUN`] = "Fusil d'Assaut",
    [`WEAPON_BULLPUPSHOTGUN`] = "Fusil Bullpup",
    [`WEAPON_MUSKET`] = "Mousquet",
    [`WEAPON_HEAVYSHOTGUN`] = "Fusil Lourd",
    [`WEAPON_DBSHOTGUN`] = "Fusil Double Canon",
    [`WEAPON_AUTOSHOTGUN`] = "Sweeper Shotgun",
    [`WEAPON_COMBATSHOTGUN`] = "Fusil de Combat",

    -- Fusils d'assaut
    [`WEAPON_ASSAULTRIFLE`] = "Fusil d'Assaut",
    [`WEAPON_ASSAULTRIFLE_MK2`] = "Fusil d'Assaut Mk II",
    [`WEAPON_CARBINERIFLE`] = "Carabine",
    [`WEAPON_CARBINERIFLE_MK2`] = "Carabine Mk II",
    [`WEAPON_ADVANCEDRIFLE`] = "Carabine Avancée",
    [`WEAPON_SPECIALCARBINE`] = "Carabine Spéciale",
    [`WEAPON_SPECIALCARBINE_MK2`] = "Carabine Spéciale Mk II",
    [`WEAPON_BULLPUPRIFLE`] = "Fusil Bullpup",
    [`WEAPON_BULLPUPRIFLE_MK2`] = "Fusil Bullpup Mk II",
    [`WEAPON_COMPACTRIFLE`] = "Fusil Compact",
    [`WEAPON_MILITARYRIFLE`] = "Fusil Militaire",
    [`WEAPON_HEAVYRIFLE`] = "Fusil Lourd",
    [`WEAPON_TACTICALRIFLE`] = "Carabine Tactique",

    -- Mitrailleuses
    [`WEAPON_MG`] = "Mitrailleuse MG",
    [`WEAPON_COMBATMG`] = "Combat MG",
    [`WEAPON_COMBATMG_MK2`] = "Combat MG Mk II",
    [`WEAPON_GUSENBERG`] = "Balayeuse Gusenberg",

    -- Snipers
    [`WEAPON_SNIPERRIFLE`] = "Fusil de Sniper",
    [`WEAPON_HEAVYSNIPER`] = "Sniper Lourd",
    [`WEAPON_HEAVYSNIPER_MK2`] = "Sniper Lourd Mk II",
    [`WEAPON_MARKSMANRIFLE`] = "Fusil Marksman",
    [`WEAPON_MARKSMANRIFLE_MK2`] = "Fusil Marksman Mk II",
    [`WEAPON_PRECISIONRIFLE`] = "Fusil de Précision",

    -- Armes de Corps à Corps
    [`WEAPON_KNIFE`] = "Couteau",
    [`WEAPON_NIGHTSTICK`] = "Matraque",
    [`WEAPON_HAMMER`] = "Marteau",
    [`WEAPON_BAT`] = "Batte de baseball",
    [`WEAPON_GOLFCLUB`] = "Club de golf",
    [`WEAPON_CROWBAR`] = "Pied-de-biche",
    [`WEAPON_BOTTLE`] = "Bouteille cassée",
    [`WEAPON_DAGGER`] = "Poignard",
    [`WEAPON_HATCHET`] = "Hachette",
    [`WEAPON_KNUCKLE`] = "Poing américain",
    [`WEAPON_MACHETE`] = "Machette",
    [`WEAPON_FLASHLIGHT`] = "Lampe torche",
    [`WEAPON_SWITCHBLADE`] = "Cran d'arrêt",
    [`WEAPON_BATTLEAXE`] = "Hache de combat",
    [`WEAPON_POOLCUE`] = "Queue de billard",
    [`WEAPON_WRENCH`] = "Clé anglaise",
    [`WEAPON_STONE_HATCHET`] = "Hachette de pierre",

    -- Lancer / Explosifs
    [`WEAPON_GRENADE`] = "Grenade",
    [`WEAPON_BZGAS`] = "Gaz BZ",
    [`WEAPON_MOLOTOV`] = "Cocktail Molotov",
    [`WEAPON_STICKYBOMB`] = "Bombe collante",
    [`WEAPON_SNOWBALL`] = "Boule de neige",
    [`WEAPON_PIPEBOMB`] = "Bombe artisanale",
    [`WEAPON_BALL`] = "Balle de baseball",
    [`WEAPON_SMOKEGRENADE`] = "Fumigène"
}

-- Normalisation 32-bit des hashs signés / non signés (Lua 5.4)
local function NormalizeHash(h)
    if not h or type(h) ~= "number" or h == 0 then return 0 end
    if h < 0 then
        return (h + 4294967296)
    end
    return h
end

local UNARMED_HASH = 2725352035 -- `WEAPON_UNARMED` normalisé unsigned

-- Remplissage bidirectionnel de WeaponLabels (clés signées & non-signées)
CreateThread(function()
    local additions = {}
    for k, v in pairs(WeaponLabels) do
        local n = NormalizeHash(k)
        if n ~= k then
            additions[n] = v
        end
    end
    for k, v in pairs(additions) do
        WeaponLabels[k] = v
    end
end)

-- Arme actuellement tenue en main
local function GetCurrentPedArmedWeapon(ped)
    if not DoesEntityExist(ped) or IsEntityDead(ped) then
        return false, 0
    end

    -- Si le joueur est dans un véhicule : masquer le HUD d'arme sauf en cas de visée / tir actif (Drive-by)
    if IsPedInAnyVehicle(ped, false) then
        if Config.HideWeaponInVehicle ~= false then
            local isDriveby = IsPedDoingDriveby(ped) or IsPlayerFreeAiming(PlayerId()) or IsPedShooting(ped) or IsControlPressed(0, 25)
            if not (Config.ShowWeaponOnlyOnDriveby and isDriveby) then
                return false, 0
            end
        end
    end

    -- 1. GetSelectedPedWeapon (hash de l'arme en main)
    local selectedHash = GetSelectedPedWeapon(ped)
    if selectedHash and selectedHash ~= 0 and selectedHash ~= -1569615261 and selectedHash ~= UNARMED_HASH then
        local normSel = NormalizeHash(selectedHash)
        if normSel ~= 0 and normSel ~= UNARMED_HASH then
            return true, selectedHash
        end
    end

    -- 2. Méthode GetCurrentPedWeapon (récupère le hash d'arme du ped)
    local _, curWeapon = GetCurrentPedWeapon(ped, false)
    if curWeapon and curWeapon ~= 0 and curWeapon ~= -1569615261 and curWeapon ~= UNARMED_HASH then
        local normCur = NormalizeHash(curWeapon)
        if normCur ~= 0 and normCur ~= UNARMED_HASH then
            return true, curWeapon
        end
    end

    local _, curWeaponTrue = GetCurrentPedWeapon(ped, true)
    if curWeaponTrue and curWeaponTrue ~= 0 and curWeaponTrue ~= -1569615261 and curWeaponTrue ~= UNARMED_HASH then
        local normCurTrue = NormalizeHash(curWeaponTrue)
        if normCurTrue ~= 0 and normCurTrue ~= UNARMED_HASH then
            return true, curWeaponTrue
        end
    end

    -- 3. Vérification native IsPedArmed (7 = 4 | 2 | 1 : arme à feu, explosif ou arme blanche tenue en main)
    if IsPedArmed(ped, 7) then
        if selectedHash and selectedHash ~= 0 and selectedHash ~= -1569615261 and selectedHash ~= UNARMED_HASH then
            return true, selectedHash
        end
        if curWeapon and curWeapon ~= 0 and curWeapon ~= -1569615261 and curWeapon ~= UNARMED_HASH then
            return true, curWeapon
        end
    end

    -- 4. Si le joueur est dans un véhicule (arme embarquée ou arme tenue en voiture)
    if IsPedInAnyVehicle(ped, false) then
        local inVehWeapon, vehWeaponHash = GetCurrentPedVehicleWeapon(ped)
        if inVehWeapon and vehWeaponHash and vehWeaponHash ~= 0 and vehWeaponHash ~= -1569615261 and vehWeaponHash ~= UNARMED_HASH then
            local normVeh = NormalizeHash(vehWeaponHash)
            if normVeh ~= 0 and normVeh ~= UNARMED_HASH then
                return true, vehWeaponHash
            end
        end
    end

    -- 5. Support ox_inventory si présent
    if exports['ox_inventory'] then
        local ok, oxWeapon = pcall(function()
            return exports['ox_inventory']:getCurrentWeapon()
        end)
        if ok and oxWeapon and oxWeapon.hash then
            local norm = NormalizeHash(oxWeapon.hash)
            if norm ~= 0 and norm ~= UNARMED_HASH and oxWeapon.hash ~= -1569615261 then
                return true, oxWeapon.hash
            end
        end
    end

    return false, 0
end

-- Données de l'arme équipée
local function GetWeaponHUDData(ped, weaponHash)
    local normHash = NormalizeHash(weaponHash)
    local data = {
        name = "Arme",
        clip = 0,
        ammo = 0,
        fireMode = "Semi-Auto",
        icon = "fa-solid fa-gun",
        isMelee = false
    }

    if not weaponHash or weaponHash == 0 or normHash == UNARMED_HASH then
        return data
    end

    -- 1. Récupération du nom d'arme via notre table WeaponLabels (supporte clés signées et non-signées)
    if WeaponLabels[weaponHash] then
        data.name = WeaponLabels[weaponHash]
    elseif WeaponLabels[normHash] then
        data.name = WeaponLabels[normHash]
    end

    -- 3. Secours ESX (pcall au cas où le format diffère)
    if data.name == "Arme" and ESX then
        pcall(function()
            if ESX.GetWeaponFromHash then
                local wData = ESX.GetWeaponFromHash(weaponHash) or ESX.GetWeaponFromHash(normHash)
                if wData and wData.label and wData.label ~= "" then
                    data.name = wData.label
                end
            end
        end)
    end

    -- 4. Détermination du groupe d'arme pour le mode de tir et l'icône FontAwesome
    local weaponGroup = 0
    pcall(function()
        if GetWeapontypeGroup then
            weaponGroup = GetWeapontypeGroup(weaponHash) or 0
        end
    end)
    if weaponGroup == 0 and GetWeaponTypeGroup then
        pcall(function()
            weaponGroup = GetWeaponTypeGroup(weaponHash) or 0
        end)
    end
    local normGroup = NormalizeHash(weaponGroup)

    -- Groupes GTA V (normalisés unsigned) :
    -- 416676503   = Melee
    -- 453432689   = Pistols
    -- 1593441988  = SMG
    -- 860032945   = Shotguns
    -- 3337201093  = Assault Rifles (-957766203 en signed)
    -- 1159398588  = MG / LMG
    -- 3082549795  = Snipers (-1212426201 en signed)
    -- 2725924767  = Heavy / Launchers (-1569042529 en signed)
    -- 3566412244  = Thrown (-728555052 en signed)

    local isMelee = (normGroup == 416676503)
    if not isMelee then
        local meleeHashes = {
            [NormalizeHash(`WEAPON_KNIFE`)] = true,
            [NormalizeHash(`WEAPON_NIGHTSTICK`)] = true,
            [NormalizeHash(`WEAPON_HAMMER`)] = true,
            [NormalizeHash(`WEAPON_BAT`)] = true,
            [NormalizeHash(`WEAPON_GOLFCLUB`)] = true,
            [NormalizeHash(`WEAPON_CROWBAR`)] = true,
            [NormalizeHash(`WEAPON_BOTTLE`)] = true,
            [NormalizeHash(`WEAPON_DAGGER`)] = true,
            [NormalizeHash(`WEAPON_HATCHET`)] = true,
            [NormalizeHash(`WEAPON_KNUCKLE`)] = true,
            [NormalizeHash(`WEAPON_MACHETE`)] = true,
            [NormalizeHash(`WEAPON_FLASHLIGHT`)] = true,
            [NormalizeHash(`WEAPON_SWITCHBLADE`)] = true,
            [NormalizeHash(`WEAPON_BATTLEAXE`)] = true,
            [NormalizeHash(`WEAPON_POOLCUE`)] = true,
            [NormalizeHash(`WEAPON_WRENCH`)] = true,
            [NormalizeHash(`WEAPON_STONE_HATCHET`)] = true,
            [NormalizeHash(`WEAPON_CANDYCANE`)] = true,
        }
        if meleeHashes[normHash] then
            isMelee = true
        end
    end

    local weaponType = "pistol"
    if isMelee then
        if normHash == NormalizeHash(`WEAPON_KNIFE`) or normHash == NormalizeHash(`WEAPON_DAGGER`) 
            or normHash == NormalizeHash(`WEAPON_SWITCHBLADE`) or normHash == NormalizeHash(`WEAPON_MACHETE`) then
            weaponType = "knife"
        else
            weaponType = "melee"
        end
        data.isMelee = true
        data.fireMode = "Corps à corps"
        data.icon = "fa-solid fa-hand-fist"
        data.clip = 1
        data.ammo = 0
    elseif normGroup == 3566412244 or normGroup == 2725924767 
        or normHash == NormalizeHash(`WEAPON_GRENADE`) 
        or normHash == NormalizeHash(`WEAPON_MOLOTOV`) 
        or normHash == NormalizeHash(`WEAPON_STICKYBOMB`) 
        or normHash == NormalizeHash(`WEAPON_PROXMINE`) 
        or normHash == NormalizeHash(`WEAPON_SMOKEGRENADE`) 
        or normHash == NormalizeHash(`WEAPON_BZGAS`) 
        or normHash == NormalizeHash(`WEAPON_PIPEBOMB`) 
        or normHash == NormalizeHash(`WEAPON_SNOWBALL`) 
        or normHash == NormalizeHash(`WEAPON_BALL`) then
        weaponType = "bomb"
        data.fireMode = "Lancer"
        data.icon = "fa-solid fa-bomb"
        local totalInPed = GetAmmoInPedWeapon(ped, weaponHash) or 0
        if totalInPed == 0 then totalInPed = GetAmmoInPedWeapon(ped, normHash) or 0 end
        data.clip = totalInPed
        data.ammo = 0
    elseif normHash == NormalizeHash(`WEAPON_STUNGUN`) then
        weaponType = "taser"
        data.fireMode = "Taser"
        data.icon = "fa-solid fa-bolt"
    elseif normGroup == 860032945 then -- Fusils à pompe
        weaponType = "shotgun"
        data.fireMode = "Pompe"
        data.icon = "fa-solid fa-gun"
    elseif normGroup == 3082549795 then -- Snipers
        weaponType = "sniper"
        data.fireMode = "Sniper"
        data.icon = "fa-solid fa-crosshairs"
    elseif normGroup == 1593441988 then -- SMG
        weaponType = "smg"
        data.fireMode = "Automatique"
        data.icon = "fa-solid fa-gun"
    elseif normGroup == 3337201093 then -- Assaut
        weaponType = "rifle"
        data.fireMode = "Automatique"
        data.icon = "fa-solid fa-gun"
    elseif normGroup == 1159398588 then -- MG
        weaponType = "mg"
        data.fireMode = "Automatique"
        data.icon = "fa-solid fa-gun"
    else
        weaponType = "pistol"
        data.fireMode = "Semi-Auto"
        data.icon = "fa-solid fa-gun"
    end
    data.weaponType = weaponType

    -- 5. Munitions (sauf armes de mêlée et de lancer)
    if not data.isMelee and data.fireMode ~= "Lancer" then
        local hasClip, ammoInClip = GetAmmoInClip(ped, weaponHash)
        if not hasClip then
            hasClip, ammoInClip = GetAmmoInClip(ped, normHash)
        end
        if hasClip and ammoInClip then
            data.clip = ammoInClip
        else
            data.clip = 0
        end

        local totalInPed = GetAmmoInPedWeapon(ped, weaponHash)
        if not totalInPed or totalInPed == 0 then
            totalInPed = GetAmmoInPedWeapon(ped, normHash)
        end
        if totalInPed and totalInPed > 0 then
            if data.clip == 0 then
                data.clip = totalInPed
                data.ammo = 0
            else
                data.ammo = math.max(0, totalInPed - data.clip)
            end
        else
            data.ammo = 0
        end

        -- Capacité maximale du chargeur
        local maxClip = 0
        pcall(function()
            if GetMaxAmmoInClip then
                maxClip = GetMaxAmmoInClip(ped, weaponHash, true) or 0
                if maxClip == 0 then
                    maxClip = GetMaxAmmoInClip(ped, normHash, true) or 0
                end
            end
        end)
        data.maxClip = maxClip

        -- Alerte munitions faibles (< 25% du chargeur ou vide)
        local isLowAmmo = false
        if data.clip == 0 then
            isLowAmmo = true
        elseif maxClip and maxClip > 0 then
            isLowAmmo = (data.clip <= math.ceil(maxClip * 0.25))
        elseif data.clip <= 3 then
            isLowAmmo = true
        end
        data.isLowAmmo = isLowAmmo
    else
        data.maxClip = 1
        data.isLowAmmo = false
    end

    -- 6. Détection des composants (silencieux, lampe torche, lunette)
    local isSilenced = false
    pcall(function()
        if IsPedCurrentWeaponSilenced then
            isSilenced = (IsPedCurrentWeaponSilenced(ped) == 1 or IsPedCurrentWeaponSilenced(ped) == true)
        end
    end)
    data.isSilenced = isSilenced

    local hasFlashlight = false
    pcall(function()
        if GetPedFlashlightState then
            local fl = GetPedFlashlightState(ped)
            hasFlashlight = (fl == 1 or fl == true)
        end
    end)
    data.hasFlashlight = hasFlashlight

    local hasScope = (weaponType == "sniper")
    data.hasScope = hasScope

    -- Détection rechargement en cours
    local isReloading = false
    pcall(function()
        if IsPedReloading then
            isReloading = (IsPedReloading(ped) == 1 or IsPedReloading(ped) == true)
        end
    end)
    data.isReloading = isReloading

    return data
end

-- Fonction globale de réinitialisation du cache d'arme pour re-synchronisation immédiate
function ResetWeaponHUDCache()
    lastWeaponHash = false
    lastAmmoClip = -1
    lastAmmoTotal = -1
    lastLowAmmo = false
    lastSilenced = false
    lastFlashlight = false
end
RegisterNetEvent('bl_hud_pl:client:resetWeaponCache', ResetWeaponHUDCache)

-- Commande de diagnostic et de test direct du HUD d'arme (/hudweapon)
RegisterCommand('hudweapon', function()
    local ped = PlayerPedId()
    local armed, curHash = GetCurrentPedArmedWeapon(ped)
    local selected = GetSelectedPedWeapon(ped)
    local isArmedNative = IsPedArmed(ped, 7)
    
    print(string.format([[
^3=======================================================
[bl_hud_pl] DIAGNOSTIC ARME EN MAIN
Ped ID: %s | IsDead: %s
Selected Weapon (GetSelectedPedWeapon): %s (Norm: %s)
IsPedArmed(ped, 7): %s
Resultat Detection Armed: %s | Hash: %s
Cache lastWeaponHash: %s
=======================================================^7]], 
        tostring(ped), tostring(IsEntityDead(ped)),
        tostring(selected), tostring(NormalizeHash(selected)),
        tostring(isArmedNative),
        tostring(armed), tostring(curHash),
        tostring(lastWeaponHash)
    ))

    if armed then
        local ok, wData = pcall(GetWeaponHUDData, ped, curHash)
        if ok and wData then
            print(string.format("^2[bl_hud_pl]^7 Arme: %s | Type: %s | Chargeur: %s/%s (Max: %s) | Mode: %s | Silencieux: %s | Lampe: %s | Alerte: %s", 
                tostring(wData.name), tostring(wData.weaponType), tostring(wData.clip), tostring(wData.ammo), tostring(wData.maxClip),
                tostring(wData.fireMode), tostring(wData.isSilenced), tostring(wData.hasFlashlight), tostring(wData.isLowAmmo)))
            
            SendNUIMessage({
                action = 'updateWeapon',
                show = true,
                weaponName = wData.name,
                clip = wData.clip,
                ammo = wData.ammo,
                maxClip = wData.maxClip,
                fireMode = wData.fireMode,
                icon = wData.icon,
                isMelee = wData.isMelee,
                weaponType = wData.weaponType,
                isLowAmmo = wData.isLowAmmo,
                isReloading = wData.isReloading,
                isSilenced = wData.isSilenced,
                hasFlashlight = wData.hasFlashlight,
                hasScope = wData.hasScope
            })
        else
            print("^1[bl_hud_pl ERROR]^7 Erreur GetWeaponHUDData: " .. tostring(wData))
        end
    else
        print("^1[bl_hud_pl]^7 Aucune arme detectee en main.")
    end
end, false)

-- --- CALCUL DYNAMIQUE DU POSITIONNEMENT AU-DESSUS DE LA MINIMAP ---

local lastMinimapState = {
    left = -1,
    bottom = -1,
    isBigmap = false,
    resX = -1,
    resY = -1
}

function GetMinimapAnchorData()
    local resX, resY = GetActiveScreenResolution()
    local aspectRatio = GetAspectRatio(false)
    local safezone = GetSafeZoneSize()
    local isBigmap = IsBigmapActive()

    -- Alignement et coordonnées natifs GTA V (Scaleform frontend.xml)
    SetScriptGfxAlign(string.byte('L'), string.byte('B'))
    local mapH = isBigmap and 0.46041666 or 0.188888
    local mapOffsetY = isBigmap and 0.022 or 0.002
    local mapOffsetX = -0.0045

    -- Coordonnées écran normalisées (0.0 à 1.0) du coin supérieur gauche de la minimap
    local rawLeftX, rawTopY = GetScriptGfxPosition(mapOffsetX, -(mapOffsetY + mapH))
    local _, rawBottomY = GetScriptGfxPosition(mapOffsetX, -mapOffsetY)
    ResetScriptGfxAlign()

    -- Sécurité si les natives renvoient une valeur inattendue
    if not rawLeftX or rawLeftX < 0 or rawLeftX > 1 then
        local safezoneOffset = (1.0 - safezone) * 0.5
        rawLeftX = safezoneOffset + 0.015
    end

    if not rawTopY or rawTopY < 0 or rawTopY > 1 then
        local safezoneOffset = (1.0 - safezone) * 0.5
        rawTopY = 1.0 - safezoneOffset - (isBigmap and 0.48 or 0.19)
    end

    local pixelLeft = math.floor(rawLeftX * resX)
    local pixelTop = math.floor(rawTopY * resY)
    local pixelBottomDist = resY - pixelTop -- Distance en pixels depuis le bas de l'écran

    local pixelWidth = math.floor(resX / (4 * aspectRatio))
    local pixelHeight = (rawBottomY and rawBottomY > rawTopY) and math.floor((rawBottomY - rawTopY) * resY) or math.floor(resY * (isBigmap and 0.46 or 0.19))

    local gapY = (Config.MinimapAnchor and Config.MinimapAnchor.gapY) or 12
    local offsetX = (Config.MinimapAnchor and Config.MinimapAnchor.offsetX) or 0

    return {
        left = math.max(10, pixelLeft + offsetX),
        bottom = pixelBottomDist + gapY,
        width = pixelWidth,
        height = pixelHeight,
        top = pixelTop,
        isBigmap = isBigmap,
        resX = resX,
        resY = resY,
        safezone = safezone,
        aspectRatio = aspectRatio
    }
end

function UpdateMinimapPosition(force)
    if Config.MinimapAnchor and Config.MinimapAnchor.enabled == false then return end
    local anchor = GetMinimapAnchorData()
    if force or anchor.left ~= lastMinimapState.left 
        or anchor.bottom ~= lastMinimapState.bottom 
        or anchor.isBigmap ~= lastMinimapState.isBigmap 
        or anchor.resX ~= lastMinimapState.resX 
        or anchor.resY ~= lastMinimapState.resY then

        lastMinimapState.left = anchor.left
        lastMinimapState.bottom = anchor.bottom
        lastMinimapState.isBigmap = anchor.isBigmap
        lastMinimapState.resX = anchor.resX
        lastMinimapState.resY = anchor.resY

        SendNUIMessage({
            action = 'updateMinimapPosition',
            position = anchor
        })
    end
end

-- Recalcule l'ancrage si la résolution, la safezone ou la bigmap change
CreateThread(function()
    while true do
        Wait(250)
        UpdateMinimapPosition(false)
    end
end)

-- --- INITIALISATION DU JOUEUR ---

function InitializePlayerData(xPlayer)
    local playerPed = PlayerPedId()
    local serverId = GetPlayerServerId(PlayerId())
    
    local accounts = {}
    local jobData = { name = "unemployed", label = "Sans-emploi", grade_label = "Citoyen" }
    local gangData = { name = "none", label = "Aucun", grade_label = "" }
    local playerName = GetPlayerName(PlayerId()) or "Joueur"
    
    if xPlayer then
        -- Données ESX
        if xPlayer.getName then playerName = xPlayer.getName() end
        if xPlayer.accounts then
            for i = 1, #xPlayer.accounts do
                local acc = xPlayer.accounts[i]
                accounts[acc.name] = acc.money
            end
        end
        if xPlayer.job then
            jobData = {
                name = xPlayer.job.name or "unemployed",
                label = xPlayer.job.label or "Sans-emploi",
                grade_label = xPlayer.job.grade_label or "Citoyen"
            }
        end
        if xPlayer.job2 then
            gangData = {
                name = xPlayer.job2.name or "none",
                label = xPlayer.job2.label or "Aucun",
                grade_label = xPlayer.job2.grade_label or ""
            }
        end
    end

    SendNUIMessage({
        action = 'initHud',
        config = {
            defaultSettings = Config.DefaultSettings,
            criticalThresholds = Config.CriticalThresholds,
            currencySymbol = Config.CurrencySymbol,
            currencyPosition = Config.CurrencyPosition
        },
        player = {
            id = serverId,
            name = playerName,
            job = jobData,
            gang = gangData,
            accounts = accounts
        }
    })

    -- Déclencher la synchronisation immédiate de l'ancrage minimap
    UpdateMinimapPosition(true)

    -- Déclencher la demande des données supplémentaires au serveur
    TriggerServerEvent('bl_hud_pl:server:requestInitialData')
end

-- Démarrage si déjà spawn (ex: restart de ressource en jeu)
AddEventHandler('onClientResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    -- Laisser le temps à ESX d'être récupéré (thread de client/events.lua)
    local timeout = GetGameTimer() + 5000
    while ESX == nil and GetGameTimer() < timeout do
        Wait(100)
    end
    Wait(500)
    if ESX and ESX.IsPlayerLoaded and ESX.IsPlayerLoaded() then
        SetHUDVisibility(true)
        InitializePlayerData(ESX.GetPlayerData())
    elseif ESX == nil then
        -- Sans ESX : comportement d'origine, HUD affiché directement
        SetHUDVisibility(true)
        InitializePlayerData(nil)
    end
    -- Sinon (joueur en sélection de personnage) : esx:playerLoaded affichera le HUD
    UpdateMinimapPosition(true)
end)

-- --- CALCUL DE LA DIRECTION & BOUSSOLE ---

local function GetCardianHeading(heading)
    if heading >= 337.5 or heading < 22.5 then
        return "N"
    elseif heading >= 22.5 and heading < 67.5 then
        return "NE"
    elseif heading >= 67.5 and heading < 112.5 then
        return "E"
    elseif heading >= 112.5 and heading < 157.5 then
        return "SE"
    elseif heading >= 157.5 and heading < 202.5 then
        return "S"
    elseif heading >= 202.5 and heading < 247.5 then
        return "SO"
    elseif heading >= 247.5 and heading < 292.5 then
        return "O"
    elseif heading >= 292.5 and heading < 337.5 then
        return "NO"
    end
    return "N"
end

local ZoneLabels = {
    ["AIRP"] = "Aéroport Int. de Los Santos",
    ["ALAMO"] = "Mer d'Alamo",
    ["ALTA"] = "Alta",
    ["ARMYB"] = "Fort Zancudo",
    ["BANHAMC"] = "Banham Canyon Dr",
    ["BANNING"] = "Banning",
    ["BEACH"] = "Vespucci Beach",
    ["BHAMCA"] = "Banham Canyon",
    ["BRADP"] = "Braddock Pass",
    ["BRADT"] = "Braddock Tunnel",
    ["BURTON"] = "Burton",
    ["CALAFB"] = "Calafia Bridge",
    ["CANNY"] = "Raton Canyon",
    ["CCREAK"] = "Cassidy Creek",
    ["CHAMH"] = "Chamberlain Hills",
    ["CHIL"] = "Vinewood Hills",
    ["CHU"] = "Chumash",
    ["CMSW"] = "Chiliad Mountain State Wilderness",
    ["CYPRE"] = "Cypress Flats",
    ["DAVIS"] = "Davis",
    ["DELBE"] = "Del Perro Beach",
    ["DELPE"] = "Del Perro",
    ["DELSOL"] = "La Puerta",
    ["DESRT"] = "Grand Senora Desert",
    ["DOWNT"] = "Downtown Los Santos",
    ["DTVINE"] = "Downtown Vinewood",
    ["EAST_V"] = "East Vinewood",
    ["EBURO"] = "El Burro Heights",
    ["ELGORL"] = "El Gordo Lighthouse",
    ["ELYSIAN"] = "Elysian Island",
    ["GALFISH"] = "Galilee",
    ["GOLF"] = "GWC and Golfing Society",
    ["GRAPES"] = "Grapeseed",
    ["GREATC"] = "Great Chaparral",
    ["HARMO"] = "Harmony",
    ["HAWICK"] = "Hawick",
    ["HORS"] = "Vinewood Racetrack",
    ["HUMLAB"] = "Humane Labs and Research",
    ["JAIL"] = "Bolingbroke Penitentiary",
    ["KOREAT"] = "Little Seoul",
    ["LACT"] = "Land Act Reservoir",
    ["LAGO"] = "Lago Zancudo",
    ["LDAM"] = "Land Act Dam",
    ["LEGSQU"] = "Legion Square",
    ["LMESA"] = "La Mesa",
    ["LOSPUER"] = "La Puerta",
    ["MIRR"] = "Mirror Park",
    ["MORN"] = "Morningwood",
    ["MOVIE"] = "Richards Majestic",
    ["MTCHIL"] = "Mount Chiliad",
    ["MTGORDO"] = "Mount Gordo",
    ["MTJOSE"] = "Mount Josiah",
    ["MURRI"] = "Murrieta Heights",
    ["NCHU"] = "North Chumash",
    ["NOOSE"] = "N.O.O.S.E",
    ["OCEANA"] = "Océan Pacifique",
    ["PALCOV"] = "Paleto Cove",
    ["PALETO"] = "Paleto Bay",
    ["PALFOR"] = "Paleto Forest",
    ["PALHIGH"] = "Palomino Highlands",
    ["PALMPOW"] = "Palmer-Taylor Power Station",
    ["PBLUFF"] = "Pacific Bluffs",
    ["PBOX"] = "Pillbox Hill",
    ["PROCOB"] = "Procopio Beach",
    ["RANCHO"] = "Rancho",
    ["RGLEN"] = "Richman Glen",
    ["RICHM"] = "Richman",
    ["ROCKF"] = "Rockford Hills",
    ["RTRAK"] = "Redwood Lights Track",
    ["SANCHIA"] = "San Chianski Mountain Range",
    ["SANDY"] = "Sandy Shores",
    ["SKID"] = "Mission Row",
    ["SLAB"] = "Stab City",
    ["STAD"] = "Maze Bank Arena",
    ["STRAW"] = "Strawberry",
    ["TATAMO"] = "Tataviam Mountains",
    ["TERMINA"] = "Terminal",
    ["TEXTI"] = "Textile City",
    ["TONGVAH"] = "Tongva Hills",
    ["TONGVAV"] = "Tongva Valley",
    ["VCANA"] = "Vespucci Canals",
    ["VESP"] = "Vespucci",
    ["VINE"] = "Vinewood",
    ["WINDF"] = "Ron Alternates Wind Farm",
    ["WVINE"] = "West Vinewood",
    ["ZANCUDO"] = "Zancudo River",
    ["ZP_ORT"] = "Port de South Los Santos",
    ["ZQ_UAR"] = "Davis Quartz"
}

-- --- DÉSACTIVATION DES HUDs & COMPOSANTS PAR DÉFAUT DE GTA 5 ---

CreateThread(function()
    while true do
        Wait(0)
        -- Désactiver le HUD d'arme par défaut de GTA 5 (icône blanche et munitions en haut à droite)
        if Config.HideDefaultWeaponHud ~= false then
            HideHudComponentThisFrame(2)  -- HUD_WEAPON_ICON (Icône de l'arme GTA 5 en haut à droite)
            HideHudComponentThisFrame(20) -- HUD_WEAPON_WHEEL_STATS
            HideHudComponentThisFrame(22) -- HUD_WEAPONS (Munitions GTA 5 par défaut)
        end

        -- Désactiver les affichages de cash natifs de GTA 5 ($ en haut à droite)
        if Config.HideDefaultCashHud ~= false then
            HideHudComponentThisFrame(3)  -- HUD_CASH
            HideHudComponentThisFrame(4)  -- HUD_MP_CASH
            HideHudComponentThisFrame(13) -- HUD_CASH_CHANGE
        end

        -- Désactiver les noms de rues & véhicules natifs de GTA 5 (au-dessus de la minimap)
        if Config.HideDefaultStreetName ~= false then
            HideHudComponentThisFrame(6)  -- HUD_VEHICLE_NAME
            HideHudComponentThisFrame(7)  -- HUD_AREA_NAME
            HideHudComponentThisFrame(8)  -- HUD_VEHICLE_CLASS
            HideHudComponentThisFrame(9)  -- HUD_STREET_NAME
        end

        -- Masquer la barre de stamina / capacité spéciale native sous la minimap
        if Config.HideDefaultStaminaBar ~= false then
            Citizen.InvokeNative(0x1DFEDD15019315A9, false) -- _SET_ABILITY_BAR_VISIBILITY_IN_MULTIPLAYER
            Citizen.InvokeNative(0x889329C80FE5963C, false) -- _SET_ALLOW_ABILITY_BAR_IN_MULTIPLAYER
        end
    end
end)

if Config.HideDefaultStaminaBar ~= false then
    CreateThread(function()
        while true do
            Wait(1000)
            local playerId = PlayerId()
            if playerId and playerId ~= -1 then
                EnableSpecialAbility(playerId, false)
                SetSpecialAbilityMultiplier(0.0)
            end
        end
    end)
end

-- --- DÉSACTIVATION DES BARRES DE SANTÉ & ARMURE NATIVES DE GTA 5 (SOUS MINIMAP) ---

if Config.HideRadarHealthArmour ~= false then
    CreateThread(function()
        local minimap = RequestScaleformMovie("minimap")
        while not HasScaleformMovieLoaded(minimap) do
            Wait(100)
        end

        SetRadarBigmapEnabled(false, false)

        while true do
            Wait(250)
            BeginScaleformMovieMethod(minimap, "SETUP_HEALTH_ARMOUR")
            ScaleformMovieMethodAddParamInt(3)
            EndScaleformMovieMethod()
        end
    end)
end

-- --- COMPTEUR DE FPS ---

local frameCount = 0
local currentFps = 60

CreateThread(function()
    while true do
        frameCount = frameCount + 1
        Wait(0)
    end
end)

CreateThread(function()
    while true do
        Wait(1000)
        currentFps = frameCount
        frameCount = 0
        SendNUIMessage({
            action = 'updateTech',
            fps = currentFps
        })
    end
end)

-- --- BOUCLE PRINCIPALE ---

CreateThread(function()
    while true do
        local isPauseMenu = IsPauseMenuActive()
        if isPauseMenu ~= lastPauseMenuState then
            lastPauseMenuState = isPauseMenu
            -- Ne pas passer par SetHUDVisibility : en sortant du menu pause, cela
            -- réaffichait un HUD volontairement masqué (sélection perso, export, etc.)
            local hudVisible = not (IsHudHiddenState and IsHudHiddenState())
            SendNUIMessage({
                action = 'setPauseMenu',
                isPaused = isPauseMenu,
                hudVisible = hudVisible
            })
            if not isPauseMenu and hudVisible then
                ResetWeaponHUDCache()
                UpdateMinimapPosition(true)
            end
        end

        if not isPauseMenu then
            local ped = PlayerPedId()
            local playerId = PlayerId()

            -- Calcul de la Santé
            local maxHealth = GetEntityMaxHealth(ped)
            local rawHealth = GetEntityHealth(ped)
            local healthPercent = 0
            if maxHealth > 100 then
                healthPercent = math.floor(((rawHealth - 100) / (maxHealth - 100)) * 100)
            else
                healthPercent = rawHealth
            end
            healthPercent = math.max(0, math.min(100, healthPercent))

            -- Calcul de l'Armure
            local rawArmor = GetPedArmour(ped)
            local armorPercent = math.max(0, math.min(100, rawArmor))

            -- Calcul de l'Oxygène / Plongée
            local oxygenPercent = 100
            if IsPedSwimmingUnderWater(ped) then
                local rawOxygen = GetPlayerUnderwaterTimeRemaining(playerId)
                oxygenPercent = math.floor((rawOxygen / 10.0) * 100)
                oxygenPercent = math.max(0, math.min(100, oxygenPercent))
            end

            -- Calcul de l'Endurance (Stamina)
            local staminaPercent = 100
            local rawStamina = GetPlayerSprintStaminaRemaining(playerId)
            if rawStamina then
                staminaPercent = math.floor(100 - rawStamina)
                staminaPercent = math.max(0, math.min(100, staminaPercent))
            end

            -- État de parole du joueur
            local isTalking = NetworkIsPlayerTalking(playerId) == 1 or NetworkIsPlayerTalking(playerId) == true
            
            -- Vérification des changements d'état
            if healthPercent ~= lastHealth or armorPercent ~= lastArmor or oxygenPercent ~= lastOxygen or staminaPercent ~= lastStamina or isTalking ~= lastTalking then
                lastHealth = healthPercent
                lastArmor = armorPercent
                lastOxygen = oxygenPercent
                lastStamina = staminaPercent
                lastTalking = isTalking

                SendNUIMessage({
                    action = 'updateStatus',
                    status = {
                        health = healthPercent,
                        armor = armorPercent,
                        oxygen = oxygenPercent,
                        stamina = staminaPercent,
                        isUnderWater = IsPedSwimmingUnderWater(ped),
                        isTalking = isTalking
                    }
                })
            end

            -- Détection Véhicule & Adaptation Minimap
            local inVehicle = IsPedInAnyVehicle(ped, false)
            if inVehicle ~= lastInVehicle then
                lastInVehicle = inVehicle
                SendNUIMessage({
                    action = 'updateVehicleState',
                    inVehicle = inVehicle
                })
                -- Si entrée en véhicule et option active, forcer le masquage immédiat du HUD d'arme
                if inVehicle and Config.HideWeaponInVehicle ~= false then
                    lastWeaponHash = false
                    lastAmmoClip = -1
                    lastAmmoTotal = -1
                    lastLowAmmo = false
                    lastSilenced = false
                    lastFlashlight = false
                    SendNUIMessage({
                        action = 'updateWeapon',
                        show = false
                    })
                end
            end

            -- Visée (sert à masquer la carte d'annonces)
            local isAiming = IsPlayerFreeAiming(playerId) == true or IsPlayerFreeAiming(playerId) == 1
            if isAiming ~= lastAiming then
                lastAiming = isAiming
                SendNUIMessage({
                    action = 'updateAiming',
                    aiming = isAiming
                })
            end

            -- Arme équipée et munitions
            local isArmed, currentWeaponHash = GetCurrentPedArmedWeapon(ped)

            -- Si désactivé dans la configuration serveur
            if Config.DefaultSettings and Config.DefaultSettings.showWeapon == false then
                isArmed = false
            end

            if isArmed and currentWeaponHash ~= 0 then
                local ok, wData = pcall(GetWeaponHUDData, ped, currentWeaponHash)
                if ok and wData then
                    if currentWeaponHash ~= lastWeaponHash or wData.clip ~= lastAmmoClip or wData.ammo ~= lastAmmoTotal 
                        or wData.isLowAmmo ~= lastLowAmmo or wData.isSilenced ~= lastSilenced or wData.hasFlashlight ~= lastFlashlight then
                        lastWeaponHash = currentWeaponHash
                        lastAmmoClip = wData.clip
                        lastAmmoTotal = wData.ammo
                        lastLowAmmo = wData.isLowAmmo
                        lastSilenced = wData.isSilenced
                        lastFlashlight = wData.hasFlashlight

                        SendNUIMessage({
                            action = 'updateWeapon',
                            show = true,
                            weaponName = wData.name,
                            clip = wData.clip,
                            ammo = wData.ammo,
                            maxClip = wData.maxClip,
                            fireMode = wData.fireMode,
                            icon = wData.icon,
                            isMelee = wData.isMelee,
                            weaponType = wData.weaponType,
                            isLowAmmo = wData.isLowAmmo,
                            isReloading = wData.isReloading,
                            isSilenced = wData.isSilenced,
                            hasFlashlight = wData.hasFlashlight,
                            hasScope = wData.hasScope
                        })
                    end
                end
            else
                if lastWeaponHash ~= false then
                    lastWeaponHash = false
                    lastAmmoClip = -1
                    lastAmmoTotal = -1
                    lastLowAmmo = false
                    lastSilenced = false
                    lastFlashlight = false
                    SendNUIMessage({
                        action = 'updateWeapon',
                        show = false
                    })
                end
            end

            -- Calcul de la Rue & Boussole
            local coords = GetEntityCoords(ped)
            local streetHash, crossHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
            local streetName = GetStreetNameFromHashKey(streetHash)
            if crossHash ~= 0 then
                local crossName = GetStreetNameFromHashKey(crossHash)
                if crossName and crossName ~= "" then
                    streetName = streetName .. " / " .. crossName
                end
            end

            local zoneHash = GetNameOfZone(coords.x, coords.y, coords.z)
            local zoneName = ZoneLabels[zoneHash] or zoneHash
            local heading = GetCardianHeading(GetEntityHeading(ped))

            if streetName ~= lastStreet or zoneName ~= lastZone or heading ~= lastHeading then
                lastStreet = streetName
                lastZone = zoneName
                lastHeading = heading

                SendNUIMessage({
                    action = 'updateCompass',
                    street = streetName,
                    zone = zoneName,
                    heading = heading,
                    deg = math.floor(GetEntityHeading(ped)) % 360
                })
            end
        end

        Wait(Config.TickRate)
    end
end)

-- --- FLASH DE TIR & DÉTECTION DU RECHARGEMENT ---
CreateThread(function()
    local lastReloadState = false
    while true do
        if lastWeaponHash and lastWeaponHash ~= false then
            local ped = PlayerPedId()
            if IsPedShooting(ped) then
                SendNUIMessage({
                    action = 'weaponShoot'
                })
            end

            local isReloading = (IsPedReloading and (IsPedReloading(ped) == 1 or IsPedReloading(ped) == true)) or false
            if isReloading ~= lastReloadState then
                lastReloadState = isReloading
                SendNUIMessage({
                    action = 'weaponReloading',
                    reloading = isReloading
                })
            end
            Wait(0)
        else
            lastReloadState = false
            Wait(250)
        end
    end
end)

-- --- SYNCHRONISATION DE LA MÉTÉO & TEMPÉRATURE ---

local weatherIcons = {
    [`CLEAR`] = { icon = "fa-solid fa-sun", color = "#f1c40f", temp = 25, label = "Ensoleillé" },
    [`EXTRASUNNY`] = { icon = "fa-solid fa-sun", color = "#e67e22", temp = 29, label = "Très ensoleillé" },
    [`CLOUDS`] = { icon = "fa-solid fa-cloud", color = "#b2bec3", temp = 20, label = "Nuageux" },
    [`OVERCAST`] = { icon = "fa-solid fa-cloud-sun", color = "#dfe6e9", temp = 19, label = "Couvert" },
    [`RAIN`] = { icon = "fa-solid fa-cloud-rain", color = "#74b9ff", temp = 16, label = "Pluvieux" },
    [`CLEARING`] = { icon = "fa-solid fa-cloud-sun-rain", color = "#74b9ff", temp = 18, label = "Éclaircies" },
    [`THUNDER`] = { icon = "fa-solid fa-bolt", color = "#f39c12", temp = 15, label = "Orageux" },
    [`SMOG`] = { icon = "fa-solid fa-smog", color = "#a4b0be", temp = 22, label = "Brumeux" },
    [`FOGGY`] = { icon = "fa-solid fa-smog", color = "#a4b0be", temp = 17, label = "Brouillard" },
    [`XMAS`] = { icon = "fa-solid fa-snowflake", color = "#81ecec", temp = -2, label = "Neige" },
    [`SNOW`] = { icon = "fa-solid fa-snowflake", color = "#81ecec", temp = -1, label = "Neige" },
    [`SNOWLIGHT`] = { icon = "fa-solid fa-snowflake", color = "#81ecec", temp = 1, label = "Neige légère" },
    [`BLIZZARD`] = { icon = "fa-solid fa-snowflake", color = "#81ecec", temp = -5, label = "Blizzard" },
    [`HALLOWEEN`] = { icon = "fa-solid fa-ghost", color = "#e17055", temp = 13, label = "Halloween" },
    [`NEUTRAL`] = { icon = "fa-solid fa-sun", color = "#f1c40f", temp = 22, label = "Tempéré" },
}

local lastWeatherHash = nil
local lastWeatherHour = -1

CreateThread(function()
    while true do
        local curWeather = GetPrevWeatherTypeHashName()
        local hour = GetClockHours()

        if curWeather ~= lastWeatherHash or hour ~= lastWeatherHour then
            lastWeatherHash = curWeather
            lastWeatherHour = hour

            local wInfo = weatherIcons[curWeather] or { icon = "fa-solid fa-sun", color = "#f1c40f", temp = 22, label = "Dégagé" }
            local isNight = (hour >= 21 or hour < 6)
            local icon = wInfo.icon
            local color = wInfo.color
            local temp = wInfo.temp

            if isNight then
                temp = temp - 4
                if icon == "fa-solid fa-sun" then
                    icon = "fa-solid fa-moon"
                    color = "#dfe6e9"
                elseif icon == "fa-solid fa-cloud-sun" then
                    icon = "fa-solid fa-cloud-moon"
                    color = "#b2bec3"
                end
            end

            SendNUIMessage({
                action = 'updateWeather',
                weather = {
                    icon = icon,
                    color = color,
                    temp = temp,
                    label = wInfo.label,
                    isNight = isNight
                }
            })
        end

        Wait(3500)
    end
end)
