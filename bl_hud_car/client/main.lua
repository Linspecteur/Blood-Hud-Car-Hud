local isHudOpen = false
local isEditModeActive = false
local isSeatbeltOn = false
local previousVelocity = vector3(0.0, 0.0, 0.0)
local previousLocalSpeed = vector3(0.0, 0.0, 0.0)
local previousSpeed = 0.0
local sessionTripKm = 0.0


-- --- FONCTION RÉCUPÉRATION DU CARBURANT ---
local function GetVehicleFuel(vehicle)
    if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then return 100 end

    -- 1. ox_fuel (exports.ox_fuel:getFuel ou GetFuel)
    if GetResourceState('ox_fuel') == 'started' then
        local success, val = pcall(function()
            local exp = exports['ox_fuel']
            if exp.getFuel then
                return exp:getFuel(vehicle)
            elseif exp.GetFuel then
                return exp:GetFuel(vehicle)
            end
        end)
        if success and val then return val end
    end

    -- 2. LegacyFuel
    if GetResourceState('LegacyFuel') == 'started' then
        local success, val = pcall(function()
            return exports['LegacyFuel']:GetFuel(vehicle)
        end)
        if success and val then return val end
    end

    -- 3. ps-fuel
    if GetResourceState('ps-fuel') == 'started' then
        local success, val = pcall(function()
            return exports['ps-fuel']:GetFuel(vehicle)
        end)
        if success and val then return val end
    end

    -- 4. cdn-fuel
    if GetResourceState('cdn-fuel') == 'started' then
        local success, val = pcall(function()
            return exports['cdn-fuel']:GetFuel(vehicle)
        end)
        if success and val then return val end
    end

    -- 5. Repli natif GTA V
    local success, fuelLevel = pcall(GetVehicleFuelLevel, vehicle)
    if success and fuelLevel and fuelLevel > 0 then
        return fuelLevel
    end

    return 100.0
end

-- --- GESTION DE LA CEINTURE DE SÉCURITÉ ---
function ToggleSeatbelt()
    if IsPauseMenuActive() then return end
    local ped = PlayerPedId()
    if not IsPedInAnyVehicle(ped, false) then return end

    local vehicle = GetVehiclePedIsIn(ped, false)
    if not vehicle or vehicle == 0 then return end
    local vehicleClass = GetVehicleClass(vehicle)
    
    -- Pas de ceinture sur deux-roues, bateaux, hélicos
    if vehicleClass == 8 or vehicleClass == 13 or vehicleClass == 14 or vehicleClass == 15 or vehicleClass == 16 then
        return
    end

    isSeatbeltOn = not isSeatbeltOn

    SendNUIMessage({
        action = 'updateSeatbelt',
        buckled = isSeatbeltOn,
        playSound = Config.PlaySeatbeltSound
    })
end

RegisterCommand(Config.SeatbeltCommand or "seatbelt", function()
    ToggleSeatbelt()
end, false)

RegisterCommand("ceinture", function()
    ToggleSeatbelt()
end, false)

if Config.EnableSeatbelt and Config.SeatbeltKey and Config.SeatbeltKey ~= "" then
    RegisterKeyMapping(Config.SeatbeltCommand or "seatbelt", "Attacher/Détacher la ceinture", "keyboard", Config.SeatbeltKey)
end

-- --- GESTION DU MODE CROISIÈRE & RÉGULATEUR DE VITESSE ---
local isCruiseOn = false
local cruiseSpeedMs = 0.0
local cruiseTargetDisplay = 0
local manualDriveMode = nil

local function ResetCruiseControl(vehicle, playSound)
    if not isCruiseOn then return end
    isCruiseOn = false
    cruiseSpeedMs = 0.0
    cruiseTargetDisplay = 0
    if vehicle and vehicle ~= 0 and DoesEntityExist(vehicle) then
        local maxSpeed = GetVehicleHandlingFloat(vehicle, "CHandlingData", "fInitialDriveMaxFlatVel")
        SetEntityMaxSpeed(vehicle, maxSpeed > 0 and maxSpeed or 1000.0)
    end
    if playSound then
        SendNUIMessage({
            action = 'playCruiseSound',
            status = 'off'
        })
    end
end

local function SetCruiseSpeedTarget(newSpeedDisplay, vehicle)
    if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then return end
    local unitMultiplier = (Config.SpeedUnit == 'MPH') and 2.236936 or 3.6
    local minSpeed = Config.CruiseMinSpeed or 20.0
    local maxSpeedHandling = GetVehicleHandlingFloat(vehicle, "CHandlingData", "fInitialDriveMaxFlatVel") * unitMultiplier
    local maxAllowed = maxSpeedHandling > 50 and maxSpeedHandling or 320.0

    local clamped = math.max(minSpeed, math.min(maxAllowed, newSpeedDisplay))
    cruiseTargetDisplay = math.floor(clamped + 0.5)
    cruiseSpeedMs = clamped / unitMultiplier
    isCruiseOn = true
    SetEntityMaxSpeed(vehicle, cruiseSpeedMs)
    SendNUIMessage({
        action = 'playCruiseSound',
        status = 'on'
    })
end

function ToggleCruiseControl(targetParam)
    if not Config.EnableCruiseControl then return end
    if IsPauseMenuActive() then return end
    local ped = PlayerPedId()
    if not IsPedInAnyVehicle(ped, false) then return end

    local vehicle = GetVehiclePedIsIn(ped, false)
    if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then return end

    -- Uniquement pour le conducteur
    if GetPedInVehicleSeat(vehicle, -1) ~= ped then return end

    local vehicleClass = GetVehicleClass(vehicle)
    -- Exclure les deux-roues, vélos, bateaux, hélicos, avions, trains
    if vehicleClass == 8 or vehicleClass == 13 or vehicleClass == 14 or vehicleClass == 15 or vehicleClass == 16 or vehicleClass == 21 then
        return
    end

    local step = Config.CruiseSpeedStep or 5

    if targetParam == "+" or targetParam == "up" then
        if isCruiseOn then
            SetCruiseSpeedTarget(cruiseTargetDisplay + step, vehicle)
        else
            local cur = GetEntitySpeed(vehicle) * ((Config.SpeedUnit == 'MPH') and 2.236936 or 3.6)
            SetCruiseSpeedTarget(cur + step, vehicle)
        end
        return
    elseif targetParam == "-" or targetParam == "down" then
        if isCruiseOn then
            SetCruiseSpeedTarget(cruiseTargetDisplay - step, vehicle)
        else
            local cur = GetEntitySpeed(vehicle) * ((Config.SpeedUnit == 'MPH') and 2.236936 or 3.6)
            SetCruiseSpeedTarget(cur - step, vehicle)
        end
        return
    elseif tonumber(targetParam) then
        SetCruiseSpeedTarget(tonumber(targetParam), vehicle)
        return
    end

    -- Sans argument : Bascule ON / OFF classique
    if isCruiseOn then
        ResetCruiseControl(vehicle, true)
    else
        local currentSpeedMs = GetEntitySpeed(vehicle)
        local unitMultiplier = (Config.SpeedUnit == 'MPH') and 2.236936 or 3.6
        local currentSpeedDisplay = currentSpeedMs * unitMultiplier
        local minSpeed = Config.CruiseMinSpeed or 20.0

        if currentSpeedDisplay < minSpeed then
            return
        end

        isCruiseOn = true
        cruiseSpeedMs = currentSpeedMs
        cruiseTargetDisplay = math.floor(currentSpeedDisplay + 0.5)
        SetEntityMaxSpeed(vehicle, currentSpeedMs)
        SendNUIMessage({
            action = 'playCruiseSound',
            status = 'on'
        })
    end
end

-- --- BOUCLE DÉDIÉE DU RÉGULATEUR DE VITESSE ---
CreateThread(function()
    while true do
        if isCruiseOn then
            local ped = PlayerPedId()
            local vehicle = GetVehiclePedIsIn(ped, false)

            if vehicle and vehicle ~= 0 and DoesEntityExist(vehicle) and GetPedInVehicleSeat(vehicle, -1) == ped and GetIsVehicleEngineRunning(vehicle) then
                local currentSpeed = GetEntitySpeed(vehicle)
                local isBraking = IsControlPressed(0, 72) or IsControlJustPressed(0, 72)
                local isHandbrake = (GetVehicleHandbrake(vehicle) == 1) or IsControlPressed(0, 76) or IsControlJustPressed(0, 76)
                local hasCrashed = (cruiseSpeedMs - currentSpeed) > 6.5

                if isBraking or isHandbrake or hasCrashed then
                    ResetCruiseControl(vehicle, true)
                else
                    -- Maintien de la vitesse tant que le joueur n'accélère pas
                    if Config.CruiseAutoThrottle and currentSpeed < (cruiseSpeedMs - 0.12) then
                        local diff = cruiseSpeedMs - currentSpeed
                        local throttle = math.min(1.0, math.max(0.35, diff * 0.8))
                        SetControlNormal(0, 71, throttle)
                    end
                end
            else
                ResetCruiseControl(vehicle, true)
            end
            Wait(0)
        else
            Wait(250)
        end
    end
end)

RegisterCommand(Config.CruiseControlCommand or "cruise", function(source, args)
    local param = args and args[1]
    ToggleCruiseControl(param)
end, false)

RegisterCommand("regulateur", function(source, args)
    local param = args and args[1]
    ToggleCruiseControl(param)
end, false)

RegisterCommand("cruise_up", function()
    ToggleCruiseControl("+")
end, false)

RegisterCommand("cruise_down", function()
    ToggleCruiseControl("-")
end, false)

-- Mode Limiteur de vitesse (/limiteur [vitesse])
RegisterCommand("limiteur", function(source, args)
    local target = args and args[1] and tonumber(args[1])
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    if not vehicle or vehicle == 0 or GetPedInVehicleSeat(vehicle, -1) ~= ped then return end

    if target and target > 0 then
        local unitMultiplier = (Config.SpeedUnit == 'MPH') and 2.236936 or 3.6
        SetEntityMaxSpeed(vehicle, target / unitMultiplier)
        SendNUIMessage({ action = 'playCruiseSound', status = 'on' })
    else
        local maxSpeed = GetVehicleHandlingFloat(vehicle, "CHandlingData", "fInitialDriveMaxFlatVel")
        SetEntityMaxSpeed(vehicle, maxSpeed > 0 and maxSpeed or 1000.0)
        SendNUIMessage({ action = 'playCruiseSound', status = 'off' })
    end
end, false)

-- Commande de sélection manuelle du mode de conduite (/mode [confort, sport, circuit, croisiere, drift, auto])
RegisterCommand("mode", function(source, args)
    local requested = args and args[1] and string.lower(args[1])
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    if not requested or requested == "auto" then
        manualDriveMode = nil
    elseif requested == "croisiere" or requested == "cruise" then
        manualDriveMode = "CROISIÈRE"
        if vehicle and vehicle ~= 0 and not isCruiseOn then
            ToggleCruiseControl()
        end
    elseif requested == "confort" or requested == "comfort" then
        manualDriveMode = "CONFORT"
        if isCruiseOn then ResetCruiseControl(vehicle, true) end
    elseif requested == "sport" then
        manualDriveMode = "SPORT"
        if isCruiseOn then ResetCruiseControl(vehicle, true) end
    elseif requested == "circuit" or requested == "track" then
        manualDriveMode = "CIRCUIT"
        if isCruiseOn then ResetCruiseControl(vehicle, true) end
    elseif requested == "drift" then
        manualDriveMode = "DRIFT"
        if isCruiseOn then ResetCruiseControl(vehicle, true) end
    end
end, false)

if Config.EnableCruiseControl and Config.CruiseControlKey and Config.CruiseControlKey ~= "" then
    RegisterKeyMapping(Config.CruiseControlCommand or "cruise", "Activer/Désactiver le mode régulateur de vitesse", "keyboard", Config.CruiseControlKey)
    RegisterKeyMapping("cruise_up", "Régulateur : Vitesse +5 km/h", "keyboard", "PAGEUP")
    RegisterKeyMapping("cruise_down", "Régulateur : Vitesse -5 km/h", "keyboard", "PAGEDOWN")
end

-- --- GESTION DES CLIGNOTANTS & FEUX DE DÉTRESSE (INDICATORS) ---
local turnSignalState = 0 -- 0 = arrêt, 1 = gauche, 2 = droite, 3 = warning
local steeringTurned = false

function ToggleTurnSignal(dir)
    if not Config.EnableBlinkers then return end
    if IsPauseMenuActive() then return end
    local ped = PlayerPedId()
    if not IsPedInAnyVehicle(ped, false) then return end
    local vehicle = GetVehiclePedIsIn(ped, false)
    if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then return end
    if GetPedInVehicleSeat(vehicle, -1) ~= ped then return end

    if dir == "left" or dir == "gauche" or dir == "g" then
        if turnSignalState == 1 then
            turnSignalState = 0
        else
            turnSignalState = 1
        end
    elseif dir == "right" or dir == "droite" or dir == "d" then
        if turnSignalState == 2 then
            turnSignalState = 0
        else
            turnSignalState = 2
        end
    elseif dir == "hazard" or dir == "warning" or dir == "detresse" or dir == "w" then
        if turnSignalState == 3 then
            turnSignalState = 0
        else
            turnSignalState = 3
        end
    else
        turnSignalState = 0
    end

    SetVehicleIndicatorLights(vehicle, 1, (turnSignalState == 1 or turnSignalState == 3)) -- 1 = Gauche
    SetVehicleIndicatorLights(vehicle, 0, (turnSignalState == 2 or turnSignalState == 3)) -- 0 = Droite
    steeringTurned = false

    if Config.PlayBlinkerSound then
        SendNUIMessage({
            action = 'playBlinkerClick',
            state = turnSignalState
        })
    end
end

RegisterCommand("cligno_left", function()
    ToggleTurnSignal("left")
end, false)

RegisterCommand("cligno_right", function()
    ToggleTurnSignal("right")
end, false)

RegisterCommand("cligno_hazard", function()
    ToggleTurnSignal("hazard")
end, false)

RegisterCommand("clignotant", function(source, args)
    local dir = args and args[1] and string.lower(args[1])
    ToggleTurnSignal(dir or "hazard")
end, false)

RegisterCommand("warning", function()
    ToggleTurnSignal("hazard")
end, false)

if Config.EnableBlinkers then
    RegisterKeyMapping("cligno_left", "Clignotant Gauche", "keyboard", Config.BlinkerLeftKey or "LEFT")
    RegisterKeyMapping("cligno_right", "Clignotant Droit", "keyboard", Config.BlinkerRightKey or "RIGHT")
    RegisterKeyMapping("cligno_hazard", "Feux de Détresse (Warning)", "keyboard", Config.BlinkerWarnKey or "DOWN")
end

-- --- AUTO-CONDUITE VIP / STAFF (AUTOPILOTE) ---
local isAutoDriveOn = false
local autoDriveDestination = nil  -- vector3 ou nil (mode libre)
local autoDriveLastToggle = 0
local autoDriveGradeValidated = nil  -- cache de validation pour éviter spam serveur
local currentStaffGrade = nil
local isCheckingPerms = false

-- Écoute en direct des attributions de grade de bl_admin_v3 / bl_admin
RegisterNetEvent('bl_admin:setGrade', function(grade)
    if grade and grade ~= '' then
        currentStaffGrade = string.lower(grade)
        autoDriveGradeValidated = nil
    end
end)

-- Réception du résultat de validation serveur
RegisterNetEvent('bl_hud_car:receiveAutoDrivePerm', function(allowed, grade)
    if grade and grade ~= '' then currentStaffGrade = string.lower(grade) end
    autoDriveGradeValidated = (allowed == true)
    isCheckingPerms = false
end)

-- Demande initiale des permissions et grades
CreateThread(function()
    Wait(1200)
    TriggerServerEvent('bl_admin:requestGrade')
    TriggerServerEvent('bl_hud_car:checkAutoDrivePerm')
end)

-- Notification au format des toasts bl_admin_v3
local function NotifyHUD(msg, nType, title, duration)
    nType = nType or 'info'
    title = title or ((nType == 'error') and 'Accès Refusé' or ((nType == 'success') and 'Succès' or ((nType == 'warning') and 'Attention' or 'Auto-Conduite')))
    duration = duration or 4000
    SendNUIMessage({
        action = 'toast',
        type = nType,
        title = title,
        message = msg,
        duration = duration
    })
end

-- Vérifie si le grade du joueur est autorisé (Multi-sources : bl_admin_v3, bl_admin, ESX, Server)
local function IsAutoDriveAllowed()
    if Config.AutoDrivePublic then return true end

    -- 1. Si déjà validé par le serveur
    if autoDriveGradeValidated == true then return true end

    local allowedGrades = Config.AutoDriveAllowedGrades or {}

    -- 2. Vérification via le grade staff mémorisé
    if currentStaffGrade and currentStaffGrade ~= '' and currentStaffGrade ~= 'user' then
        for _, a in ipairs(allowedGrades) do
            if string.lower(a) == currentStaffGrade then
                autoDriveGradeValidated = true
                return true
            end
        end
    end

    -- 3. Vérification via export bl_admin_v3
    if GetResourceState('bl_admin_v3') == 'started' then
        local success, grade = pcall(function()
            return exports['bl_admin_v3']:GetPlayerGrade()
        end)
        if success and grade and grade ~= '' and grade ~= 'user' then
            currentStaffGrade = string.lower(grade)
            for _, a in ipairs(allowedGrades) do
                if string.lower(a) == currentStaffGrade then
                    autoDriveGradeValidated = true
                    return true
                end
            end
        end
    end

    -- 4. Vérification via export bl_admin
    if GetResourceState('bl_admin') == 'started' then
        local success, grade = pcall(function()
            return exports['bl_admin']:GetPlayerGrade()
        end)
        if success and grade and grade ~= '' and grade ~= 'user' then
            currentStaffGrade = string.lower(grade)
            for _, a in ipairs(allowedGrades) do
                if string.lower(a) == currentStaffGrade then
                    autoDriveGradeValidated = true
                    return true
                end
            end
        end
    end

    -- 5. Vérification via ESX PlayerData
    if ESX and ESX.GetPlayerData then
        local pData = ESX.GetPlayerData()
        if pData and pData.group and pData.group ~= '' and pData.group ~= 'user' then
            local grp = string.lower(pData.group)
            for _, a in ipairs(allowedGrades) do
                if string.lower(a) == grp then
                    autoDriveGradeValidated = true
                    return true
                end
            end
        end
    end

    -- 6. Requête asynchrone au serveur si non résolu
    if not isCheckingPerms then
        isCheckingPerms = true
        TriggerServerEvent('bl_hud_car:checkAutoDrivePerm')
    end

    return (autoDriveGradeValidated == true)
end

local function StopAutoDrive(silent)
    if not isAutoDriveOn then return end
    isAutoDriveOn = false
    autoDriveDestination = nil
    local ped = PlayerPedId()
    ClearPedTasks(ped)
    SendNUIMessage({ action = 'updateAutoDrive', active = false })
    if not silent then
        NotifyHUD("Auto-conduite désactivée. Vous reprenez le contrôle du véhicule.", 'warning', 'Auto-Conduite', 3000)
    end
end

-- Récupère les coordonnées du repère GPS (Waypoint) placé sur la carte
local function GetWaypointCoords()
    if not IsWaypointActive() then return nil end
    local waypoint = GetFirstBlipInfoId(8) -- 8 = Blip Waypoint GTA V
    if not DoesBlipExist(waypoint) then return nil end

    local coords = GetBlipInfoIdCoord(waypoint)
    local foundGround, groundZ = GetGroundZFor_3dCoord(coords.x, coords.y, 1000.0, false)
    if foundGround then
        coords = vector3(coords.x, coords.y, groundZ)
    else
        coords = vector3(coords.x, coords.y, 0.0)
    end
    return coords
end

local function StartAutoDrive(destination)
    if not Config.EnableAutoDrive then return end
    local ped = PlayerPedId()
    if not IsPedInAnyVehicle(ped, false) then
        NotifyHUD("Vous devez être à bord d'un véhicule pour activer l'auto-conduite.", 'warning', 'Attention', 3500)
        return
    end

    local vehicle = GetVehiclePedIsIn(ped, false)
    if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then return end
    if GetPedInVehicleSeat(vehicle, -1) ~= ped then
        NotifyHUD("Vous devez être installé au siège conducteur pour activer l'auto-conduite.", 'warning', 'Attention', 3500)
        return
    end

    -- Anti-spam (délai 1.5s entre bascules)
    local now = GetGameTimer()
    if (now - autoDriveLastToggle) < 1500 then return end
    autoDriveLastToggle = now

    -- Vérification d'accès VIP / Staff
    if not IsAutoDriveAllowed() then
        NotifyHUD(Config.AutoDriveAccessDeniedMsg or "L'auto-conduite autonome est réservée aux membres VIP et Staff.", 'error', 'Accès Refusé', 4500)
        return
    end

    -- Résolution du point de destination (obligatoirement un repère GPS ou coordonnées manuelles)
    local targetCoords = destination
    if not targetCoords then
        targetCoords = GetWaypointCoords()
    end

    -- Si aucun repère GPS n'est actif, refuser et avertir le joueur
    if not targetCoords then
        NotifyHUD(Config.AutoDriveNoWaypointMsg or "Veuillez d'abord placer un repère GPS sur votre carte pour activer l'auto-conduite.", 'warning', 'Point GPS Requis', 4500)
        return
    end

    local speedMs = ((Config.AutoDriveSpeed or 80.0) / 3.6)
    local driveStyle = Config.AutoDriveStyle or 786603
    local stopRadius = Config.AutoDriveStopRadius or 12.0

    -- Engagement de la conduite autonome vers le repère GPS
    ClearPedTasks(ped)
    TaskVehicleDriveToCoordLongrange(ped, vehicle, targetCoords.x, targetCoords.y, targetCoords.z, speedMs, driveStyle, stopRadius)
    SetDriveTaskCruiseSpeed(ped, speedMs)
    SetDriveTaskDrivingStyle(ped, driveStyle)
    SetDriverAbility(ped, 1.0)
    SetDriverAggressiveness(ped, 0.0)

    autoDriveDestination = targetCoords
    isAutoDriveOn = true

    SendNUIMessage({ action = 'updateAutoDrive', active = true, mode = 'destination' })
    NotifyHUD("Itinéraire engagé — Trajet automatique vers votre point GPS.", 'info', 'Auto-Conduite', 4000)
end

function ToggleAutoDrive()
    if isAutoDriveOn then
        StopAutoDrive(false)
    else
        StartAutoDrive(nil)
    end
end

-- Boucle de surveillance auto-conduite (arrêt automatique si freinage / sortie / repère retiré / point GPS atteint)
CreateThread(function()
    while true do
        if isAutoDriveOn then
            local ped = PlayerPedId()
            local vehicle = GetVehiclePedIsIn(ped, false)

            if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) or GetPedInVehicleSeat(vehicle, -1) ~= ped then
                -- Joueur sorti ou passager → arrêt immédiat
                StopAutoDrive(true)
            else
                local isBraking = IsControlJustPressed(0, 72) or IsControlPressed(0, 72)
                local isHandbrake = IsControlJustPressed(0, 76) or (GetVehicleHandbrake(vehicle) == 1)

                if isBraking or isHandbrake then
                    StopAutoDrive(false)
                elseif autoDriveDestination then
                    -- 1. Si le joueur a retiré son point GPS pendant le trajet
                    if not IsWaypointActive() then
                        StopAutoDrive(false)
                        NotifyHUD("Repère GPS retiré. L'auto-conduite a été interrompue.", 'warning', 'Auto-Conduite', 3500)
                    else
                        -- 2. Si le joueur a déplacé son point GPS, recalculer dynamiquement l'itinéraire
                        local currentWp = GetWaypointCoords()
                        if currentWp then
                            local diff = #(vector2(currentWp.x, currentWp.y) - vector2(autoDriveDestination.x, autoDriveDestination.y))
                            if diff > 25.0 then
                                autoDriveDestination = currentWp
                                local speedMs = ((Config.AutoDriveSpeed or 80.0) / 3.6)
                                local driveStyle = Config.AutoDriveStyle or 786603
                                local stopRadius = Config.AutoDriveStopRadius or 12.0
                                ClearPedTasks(ped)
                                TaskVehicleDriveToCoordLongrange(ped, vehicle, currentWp.x, currentWp.y, currentWp.z, speedMs, driveStyle, stopRadius)
                                SetDriveTaskCruiseSpeed(ped, speedMs)
                                SetDriveTaskDrivingStyle(ped, driveStyle)
                                SetDriverAbility(ped, 1.0)
                                NotifyHUD("Itinéraire mis à jour vers le nouveau repère GPS.", 'info', 'Auto-Conduite', 3000)
                            end
                        end

                        -- 3. Vérification de l'arrivée à destination (distance 2D horizontale)
                        local pos = GetEntityCoords(vehicle)
                        local dist2D = #(vector2(pos.x, pos.y) - vector2(autoDriveDestination.x, autoDriveDestination.y))
                        if dist2D <= (Config.AutoDriveStopRadius or 12.0) then
                            StopAutoDrive(false)
                            NotifyHUD("Destination GPS atteinte avec succès. Vous reprenez les commandes.", 'success', 'Destination Atteinte', 4500)
                        end
                    end
                end
            end
            Wait(150)
        else
            Wait(500)
        end
    end
end)

-- Commandes
RegisterCommand("autopilote_toggle", function()
    ToggleAutoDrive()
end, false)

RegisterCommand("autopilote", function(source, args)
    if args and args[1] and args[2] and args[3] then
        local x, y, z = tonumber(args[1]), tonumber(args[2]), tonumber(args[3])
        if x and y and z then
            if isAutoDriveOn then StopAutoDrive(true) end
            StartAutoDrive(vector3(x, y, z))
        else
            NotifyHUD("Coordonnées GPS invalides. Usage : /autopilote [X] [Y] [Z]", 'warning', 'Syntaxe Invalide', 3500)
        end
    else
        ToggleAutoDrive()
    end
end, false)

RegisterCommand("autopilote_stop", function()
    StopAutoDrive(false)
end, false)

if Config.EnableAutoDrive and Config.AutoDriveKey and Config.AutoDriveKey ~= "" then
    RegisterKeyMapping("autopilote_toggle", "Auto-Conduite VIP/Staff — Activer/Désactiver", "keyboard", Config.AutoDriveKey)
end


-- --- MASQUAGE DU HUD NATIF GTA V EN VÉHICULE (ARME & NOMS DE VÉHICULES) ---
CreateThread(function()
    while true do
        local ped = PlayerPedId()
        if IsPedInAnyVehicle(ped, false) then
            if Config.HideDefaultWeaponHud ~= false then
                HideHudComponentThisFrame(2)  -- HUD_WEAPON_ICON (Icône de l'arme GTA 5 en haut à droite)
                HideHudComponentThisFrame(20) -- HUD_WEAPON_WHEEL_STATS
                HideHudComponentThisFrame(22) -- HUD_WEAPONS (Munitions GTA 5 par défaut)
            end
            if Config.HideDefaultVehicleName ~= false then
                HideHudComponentThisFrame(6)  -- HUD_VEHICLE_NAME (Nom du véhicule GTA 5 en bas à droite)
                HideHudComponentThisFrame(7)  -- HUD_AREA_NAME
                HideHudComponentThisFrame(8)  -- HUD_VEHICLE_CLASS
                HideHudComponentThisFrame(9)  -- HUD_STREET_NAME
            end
            Wait(0)
        else
            Wait(500)
        end
    end
end)

-- --- BOUCLE PRINCIPALE SPEEDOMETER ---
CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local inVehicle = IsPedInAnyVehicle(ped, false)

        if inVehicle then
            local isPaused = IsPauseMenuActive() or IsScreenFadedOut()

            if isPaused then
                if isHudOpen then
                    isHudOpen = false
                    SendNUIMessage({
                        action = 'showSpeedo',
                        show = false
                    })
                end
                Wait(200)
            else
                local vehicle = GetVehiclePedIsIn(ped, false)

                if vehicle and vehicle ~= 0 and DoesEntityExist(vehicle) then
                    local vehicleClass = GetVehicleClass(vehicle)

                    if not isHudOpen then
                        isHudOpen = true
                        SendNUIMessage({
                            action = 'showSpeedo',
                            show = true,
                            unit = Config.SpeedUnit or 'KMH',
                            scale = Config.HudScale or 1.0,
                            showShiftLights = Config.ShowShiftLights ~= false
                        })
                    end

                -- 1. Vitesse
                local rawSpeed = GetEntitySpeed(vehicle)
                local speed = 0
                if Config.SpeedUnit == 'MPH' then
                    speed = math.floor(rawSpeed * 2.236936 + 0.5)
                else
                    speed = math.floor(rawSpeed * 3.6 + 0.5)
                end

                -- 2. RPM (Tours/minute 0.0 à 1.0)
                local isEngineRunning = GetIsVehicleEngineRunning(vehicle)
                local rpm = isEngineRunning and GetVehicleCurrentRpm(vehicle) or 0.0

                -- 3. Rapport de vitesse (Gear)
                local gear = GetVehicleCurrentGear(vehicle)
                local gearDisplay = tostring(gear)
                if not isEngineRunning then
                    gearDisplay = "P"
                elseif rawSpeed > 0.5 and GetEntitySpeedVector(vehicle, true).y < 0.0 then
                    gearDisplay = "R"
                elseif gear == 0 then
                    gearDisplay = "N"
                end

                -- 4. Carburant
                local fuel = math.floor(GetVehicleFuel(vehicle))

                -- 5. Santé moteur (0-1000 -> 0-100%)
                local rawEngine = GetVehicleEngineHealth(vehicle)
                local enginePercent = math.max(0, math.min(100, math.floor(rawEngine / 10.0)))

                -- 5b. Santé carrosserie / châssis (0-1000 -> 0-100%)
                local rawBody = GetVehicleBodyHealth(vehicle)
                local bodyPercent = math.max(0, math.min(100, math.floor(rawBody / 10.0)))

                -- 6. Éclairage
                local _, lightsOn, highbeamsOn = GetVehicleLightsState(vehicle)
                local headlights = (lightsOn == 1 or highbeamsOn == 1)
                local highbeams = (highbeamsOn == 1)

                -- 7. Verrouillage
                local lockStatus = GetVehicleDoorLockStatus(vehicle)
                local isLocked = (lockStatus == 2 or lockStatus == 3)

                -- 8. Clignotants & Frein à main
                local indicatorLights = GetVehicleIndicatorLights(vehicle)
                local leftBlinker = (turnSignalState == 1 or turnSignalState == 3 or indicatorLights == 1 or indicatorLights == 3)
                local rightBlinker = (turnSignalState == 2 or turnSignalState == 3 or indicatorLights == 2 or indicatorLights == 3)
                local handbrake = (GetVehicleHandbrake(vehicle) == 1 or GetVehicleHandbrake(vehicle) == true)

                -- Coupe le clignotant après le virage
                if turnSignalState == 1 or turnSignalState == 2 then
                    local steerAngle = GetVehicleSteeringAngle(vehicle)
                    if turnSignalState == 1 then
                        if steerAngle > 12.0 then
                            steeringTurned = true
                        elseif steeringTurned and steerAngle < 3.0 then
                            ToggleTurnSignal("off")
                        end
                    elseif turnSignalState == 2 then
                        if steerAngle < -12.0 then
                            steeringTurned = true
                        elseif steeringTurned and steerAngle > -3.0 then
                            ToggleTurnSignal("off")
                        end
                    end
                end



                -- 9. Télémétrie Cockpit 2027 Haute Définition
                local deltaMs = (Config.RefreshRate or 50) / 1000.0
                local currentVelocity = GetEntityVelocity(vehicle)
                local currentLocalSpeed = GetEntitySpeedVector(vehicle, true)

                -- Nom du véhicule
                local model = GetEntityModel(vehicle)
                local rawName = GetDisplayNameFromVehicleModel(model)
                local label = GetLabelText(rawName)
                local vehicleName = (label ~= "NULL" and label) or rawName or "VÉHICULE"

                -- Accéléromètre G-Force 2D temps réel (longitudinal & latéral)
                local deltaLocal = (currentLocalSpeed - previousLocalSpeed) / deltaMs
                local gLat = math.max(-2.5, math.min(2.5, math.floor((deltaLocal.x / 9.81) * 100) / 100))
                local gLong = math.max(-2.5, math.min(2.5, math.floor((deltaLocal.y / 9.81) * 100) / 100))
                local gForce = math.min(2.5, math.floor(math.sqrt(gLat^2 + gLong^2) * 100) / 100)

                -- Détection Dérive & Mode de conduite dynamique (En Français)
                local isDrifting = isEngineRunning and rawSpeed > 3.0 and math.abs(currentLocalSpeed.x) > 3.0
                local driveMode = "CONFORT"
                if manualDriveMode then
                    driveMode = manualDriveMode
                elseif isDrifting then
                    driveMode = "DRIFT"
                elseif isCruiseOn then
                    driveMode = "CROISIÈRE"
                elseif speed > 115 or rpm > 0.80 then
                    driveMode = "CIRCUIT"
                elseif speed > 55 or rpm > 0.45 then
                    driveMode = "SPORT"
                end

                -- Jauge Turbo Haute Définition (-1.0 à +2.0 BAR : Dépression / Boost)
                local turbo = 0.0
                if isEngineRunning then
                    local hasTurboMod = IsToggleModOn(vehicle, 18)
                    local maxBoost = hasTurboMod and 1.85 or 1.25
                    if rawSpeed < 1.0 and rpm < 0.25 then
                        turbo = -0.5
                    elseif rawSpeed > 1.0 and (previousSpeed - rawSpeed) > 0.4 then
                        -- Dépression au lever de pied / frein moteur
                        turbo = -0.8
                    else
                        local boostCurve = (rpm ^ 1.5) * (maxBoost + 0.6) - 0.6
                        turbo = math.max(-0.8, math.min(maxBoost, boostCurve))
                    end
                    turbo = math.floor(turbo * 100) / 100
                end

                -- Température moteur (°C)
                local rawTemp = GetVehicleEngineTemperature(vehicle)
                local engineTemp = 90
                if rawTemp and rawTemp > 0 then
                    engineTemp = math.floor(rawTemp)
                else
                    engineTemp = math.floor(86 + (100 - enginePercent) * 0.4 + (rpm * 10))
                end

                -- TPMS (Détection crevaison pneu)
                local isTyreBurst = false
                for wheelIndex = 0, 5 do
                    if IsVehicleTyreBurst(vehicle, wheelIndex, false) then
                        isTyreBurst = true
                        break
                    end
                end

                -- ABS actif au freinage intense
                local isAbsActive = false
                if rawSpeed > 5.0 and not handbrake then
                    local decel = (previousSpeed - rawSpeed) / deltaMs
                    if decel > 7.5 then
                        isAbsActive = true
                    end
                end

                -- Traction Control / ESP actif lors du patinage ou drift
                local isTcActive = false
                if isEngineRunning and rawSpeed > 1.0 then
                    if math.abs(currentLocalSpeed.x) > 2.2 or (rpm > 0.6 and rawSpeed < 3.0) then
                        isTcActive = true
                    end
                end

                -- Odomètre et Autonomie restante
                sessionTripKm = sessionTripKm + (rawSpeed * deltaMs / 1000.0)
                local fuelRange = math.floor(fuel * 4.8)
                local tripDisplay = math.floor(sessionTripKm * 10) / 10
                local odoDisplay = math.floor(14820 + sessionTripKm)

                -- 10. Envoi NUI Complet 2027
                SendNUIMessage({
                    action = 'updateSpeedo',
                    speed = speed,
                    rpm = rpm,
                    gear = gearDisplay,
                    fuel = fuel,
                    fuelRange = fuelRange,
                    engine = enginePercent,
                    engineTemp = engineTemp,
                    body = bodyPercent,
                    seatbelt = isSeatbeltOn,
                    locked = isLocked,
                    headlights = headlights,
                    highbeams = highbeams,
                    leftBlinker = leftBlinker,
                    rightBlinker = rightBlinker,
                    handbrake = handbrake,
                    unit = Config.SpeedUnit or 'KMH',
                    cruise = isCruiseOn and cruiseTargetDisplay or false,
                    cruiseKey = Config.CruiseControlKey or "Y",
                    vehicleName = vehicleName,
                    driveMode = driveMode,
                    turbo = turbo,
                    gForce = gForce,
                    gLat = gLat,
                    gLong = gLong,
                    tpms = isTyreBurst,
                    abs = isAbsActive,
                    tc = isTcActive,
                    trip = tripDisplay,
                    odo = odoDisplay,
                    showShiftLights = Config.ShowShiftLights ~= false,
                    autoDrive = isAutoDriveOn,
                    autoDriveKey = Config.AutoDriveKey or "G"
                })


                -- 11. Crash éjection sans ceinture
                if Config.EjectOnCrash and not isSeatbeltOn and (vehicleClass ~= 8 and vehicleClass ~= 13) then
                    local speedDiff = #(previousVelocity - currentVelocity) * 3.6

                    if speedDiff > Config.EjectionSpeed then
                        local coords = GetEntityCoords(ped)
                        local forwardVector = GetEntityForwardVector(vehicle)
                        SetEntityCoords(ped, coords.x + forwardVector.x * 1.5, coords.y + forwardVector.y * 1.5, coords.z + 0.5, true, true, true, true)
                        SetPedToRagdoll(ped, 4000, 4000, 0, false, false, false)
                        ApplyForceToEntity(ped, 1, forwardVector.x * 20.0, forwardVector.y * 20.0, 5.0, 0.0, 0.0, 0.0, 0, false, true, true, false, true)
                        local damage = math.min(100, math.floor(speedDiff * 0.6))
                        ApplyDamageToPed(ped, damage, false)
                    end
                end

                previousVelocity = currentVelocity
                previousLocalSpeed = currentLocalSpeed
                previousSpeed = rawSpeed
            end

            Wait(Config.RefreshRate or 50)
        end
    else
        if isHudOpen and not isEditModeActive then
            isHudOpen = false
            isSeatbeltOn = false
            turnSignalState = 0
            steeringTurned = false
            ResetCruiseControl(GetVehiclePedIsIn(ped, true))
            previousVelocity = vector3(0.0, 0.0, 0.0)
            previousLocalSpeed = vector3(0.0, 0.0, 0.0)
            previousSpeed = 0.0
            SendNUIMessage({
                action = 'showSpeedo',
                show = false
            })
        end
        Wait(750) -- Économique quand le joueur est à pied
    end
    end
end)

-- --- GESTION DU DÉPLACEMENT / POSITIONNEMENT SPEEDOMETER ---
isEditModeActive = false

function StartCarHudEditMode(fromPlayerHud)
    if Config.EnablePositionCustomization == false then return end
    isEditModeActive = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'setEditMode',
        active = true,
        fromPlayerHud = fromPlayerHud == true,
        scale = Config.HudScale or 1.0,
        unit = Config.SpeedUnit or 'KMH'
    })
end

RegisterNetEvent('bl_hud_car:client:startEditMode', function(fromPlayerHud)
    StartCarHudEditMode(fromPlayerHud)
end)

local editCmd = Config.CarHudEditCommand or "carhud"
RegisterCommand(editCmd, function()
    StartCarHudEditMode(false)
end, false)

RegisterNUICallback('closeEditMode', function(data, cb)
    isEditModeActive = false
    SetNuiFocus(false, false)
    local ped = PlayerPedId()
    if not IsPedInAnyVehicle(ped, false) then
        SendNUIMessage({
            action = 'showSpeedo',
            show = false
        })
    end
    if data and data.fromPlayerHud then
        TriggerEvent('bl_hud_pl:client:openSettings')
    end
    cb('ok')
end)

RegisterNUICallback('savePosition', function(data, cb)
    if Config.Debug then
        print("[bl_hud_car] Position du Speedometer sauvegardée.")
    end
    cb('ok')
end)

-- --- EXPORTS ---

exports('ToggleSeatbelt', function()
    ToggleSeatbelt()
end)

exports('StartEditMode', function()
    StartCarHudEditMode(false)
end)

exports('ToggleCruise', function()
    if ToggleCruiseControl then
        ToggleCruiseControl()
    end
end)

exports('IsSeatbeltOn', function()
    return isSeatbeltOn
end)

