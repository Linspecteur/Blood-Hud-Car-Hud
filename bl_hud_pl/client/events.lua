-- Déclarées AVANT le thread ESX : sinon `isPlayerLoaded = true` dans le thread
-- écrivait une variable globale et la locale restait à false (HUD caché après un restart).
local isSettingsOpen = false
local isCinematicActive = false
local isPlayerLoaded = false
local isHudHidden = false

ESX = nil

CreateThread(function()
    while ESX == nil do
        if exports['es_extended'] then
            pcall(function()
                ESX = exports['es_extended']:getSharedObject()
            end)
        end
        if ESX == nil then
            TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        end
        Wait(100)
    end
    if ESX and ESX.IsPlayerLoaded and ESX.IsPlayerLoaded() then
        isPlayerLoaded = true
    end
end)

-- Annonces actives : config.lua par défaut, remplacées par celles enregistrées sur le serveur
CurrentAnnouncements = Config.Announcements

-- Les annonces enregistrées sur le serveur ne contiennent pas les réglages d'affichage :
-- on y ajoute toujours ceux de config.lua (mode périodique, masquages)
function GetAnnouncementsPayload()
    local payload = {}
    for k, v in pairs(CurrentAnnouncements or {}) do payload[k] = v end
    payload.display = Config.Announcements and Config.Announcements.display or nil
    return payload
end

function IsHudHiddenState()
    return isHudHidden
end

CurrentHunger = 100
CurrentThirst = 100
CurrentStress = 0
local starvationGraceTime = 0

-- --- GESTION DE LA VISIBILITÉ (MULTICHARACTER / SPAWN) ---

function SetHUDVisibility(visible)
    isHudHidden = not visible
    if visible then
        if ResetWeaponHUDCache then
            ResetWeaponHUDCache()
        end
        if UpdateMinimapPosition then
            UpdateMinimapPosition(true)
        end
    end
    SendNUIMessage({
        action = 'setHudVisible',
        visible = visible
    })
end

-- Masquer lors du logout ou déconnexion
RegisterNetEvent('esx:onPlayerLogout', function()
    isPlayerLoaded = false
    SetHUDVisibility(false)
end)

-- Écouteurs pour tous les systèmes de multicharacter (bl_multicharacter, esx_multicharacter, qb-multicharacter, etc.)
RegisterNetEvent('bl_hud:toggle', function(visible) SetHUDVisibility(visible) end)
RegisterNetEvent('bl_hud:hide', function(hide) SetHUDVisibility(not hide) end)
RegisterNetEvent('bloodleak:hideHud', function(hide) SetHUDVisibility(not hide) end)
RegisterNetEvent('bloodleak_hud:toggle', function(visible) SetHUDVisibility(visible) end)
RegisterNetEvent('esx_hud:toggle', function(visible) SetHUDVisibility(visible) end)
RegisterNetEvent('hud:toggle', function(visible) SetHUDVisibility(visible) end)
RegisterNetEvent('ui:toggle', function(visible) SetHUDVisibility(visible) end)
RegisterNetEvent('bl_hud_pl:client:setHudVisible', function(visible) SetHUDVisibility(visible) end)

-- --- ÉVÉNEMENTS ESX & SYNCHRONISATION ---

RegisterNetEvent('esx:playerLoaded', function(xPlayer)
    isPlayerLoaded = true
    Wait(500)
    SetHUDVisibility(true)
    if ResetWeaponHUDCache then
        ResetWeaponHUDCache()
    end
    InitializePlayerData(xPlayer)
end)

AddEventHandler('playerSpawned', function()
    starvationGraceTime = GetGameTimer() + 5000
    if isPlayerLoaded then
        SetHUDVisibility(true)
        if ResetWeaponHUDCache then
            ResetWeaponHUDCache()
        end
        if UpdateMinimapPosition then
            UpdateMinimapPosition(true)
        end
    end
end)

-- Réception complète des données initiales serveur (Nom RP, ID, Job, Comptes, Ping)
RegisterNetEvent('bl_hud_pl:client:receiveInitialData', function(data)
    if not data then return end
    if ResetWeaponHUDCache then
        ResetWeaponHUDCache()
    end
    if type(data.announcements) == 'table' then
        CurrentAnnouncements = data.announcements
    end

    SendNUIMessage({
        action = 'initHud',
        player = {
            id = data.id,
            name = data.name,
            job = data.job,
            accounts = data.accounts
        },
        config = {
            defaultSettings = Config.DefaultSettings,
            announcements = GetAnnouncementsPayload()
        }
    })

    if data.playersCount then
        SendNUIMessage({
            action = 'updatePlayersCount',
            count = data.playersCount
        })
    end

    if data.ping then
        SendNUIMessage({
            action = 'updateTech',
            ping = data.ping
        })
    end

    if data.defaultPositions then
        SendNUIMessage({
            action = 'setDefaultPositions',
            positions = data.defaultPositions
        })
    end
end)

RegisterNetEvent('bl_hud_pl:client:setAnnouncements', function(announcements)
    if type(announcements) ~= 'table' then return end
    CurrentAnnouncements = announcements
    SendNUIMessage({
        action = 'setAnnouncements',
        announcements = GetAnnouncementsPayload()
    })
end)

-- Réponse du serveur : le joueur a-t-il le droit de modifier les annonces ?
RegisterNetEvent('bl_hud_pl:client:setAdmin', function(isAdmin)
    SendNUIMessage({
        action = 'setAdmin',
        isAdmin = isAdmin == true
    })
end)

RegisterNetEvent('bl_hud_pl:client:applyServerDefaultPositions', function(positions)
    SendNUIMessage({
        action = 'setDefaultPositions',
        positions = positions
    })
end)

RegisterNetEvent('esx:setJob', function(job)
    SendNUIMessage({
        action = 'updateJob',
        job = {
            name = job.name,
            label = job.label or "Sans-emploi",
            grade = job.grade,
            grade_label = job.grade_label or "Citoyen"
        }
    })
    -- Rafraîchir les données de compte/société
    TriggerServerEvent('bl_hud_pl:server:requestInitialData')
end)

RegisterNetEvent('esx:setJob2', function(job2)
    if job2 then
        SendNUIMessage({
            action = 'updateGang',
            gang = {
                name = job2.name,
                label = job2.label or "Non affilié",
                grade = job2.grade,
                grade_label = job2.grade_label or ""
            }
        })
    end
end)

-- Synchronisation d'un compte spécifique ESX
RegisterNetEvent('esx:setAccountMoney', function(account)
    if account and account.name then
        SendNUIMessage({
            action = 'updateAccount',
            name = account.name,
            money = account.money or 0
        })
    end
end)

RegisterNetEvent('bl_hud_pl:client:updateAccount', function(accountName, money)
    SendNUIMessage({
        action = 'updateAccount',
        name = accountName,
        money = money or 0
    })
end)

local function sanitizeNumber(val, default)
    if val == nil then return default end
    local n = tonumber(val)
    if n == nil or n ~= n then return default end
    return n
end

-- Synchronisation esx_status (Faim, Soif, Stress)
RegisterNetEvent('esx_status:onTick', function(statuses)
    if not statuses then return end
    local hunger = CurrentHunger or 100
    local thirst = CurrentThirst or 100
    local stress = CurrentStress or 0

    for i = 1, #statuses do
        local status = statuses[i]
        if status and status.name then
            if status.name == 'hunger' then
                local p = sanitizeNumber(status.percent, nil)
                local v = sanitizeNumber(status.val, nil)
                if p ~= nil then
                    hunger = math.floor(p)
                elseif v ~= nil then
                    hunger = math.floor(v / 10000)
                end
            elseif status.name == 'thirst' then
                local p = sanitizeNumber(status.percent, nil)
                local v = sanitizeNumber(status.val, nil)
                if p ~= nil then
                    thirst = math.floor(p)
                elseif v ~= nil then
                    thirst = math.floor(v / 10000)
                end
            elseif status.name == 'stress' then
                local p = sanitizeNumber(status.percent, nil)
                local v = sanitizeNumber(status.val, nil)
                if p ~= nil then
                    stress = math.floor(p)
                elseif v ~= nil then
                    stress = math.floor(v / 10000)
                end
            end
        end
    end

    hunger = math.max(0, math.min(100, sanitizeNumber(hunger, 100)))
    thirst = math.max(0, math.min(100, sanitizeNumber(thirst, 100)))
    stress = math.max(0, math.min(100, sanitizeNumber(stress, 0)))

    CurrentHunger = hunger
    CurrentThirst = thirst
    CurrentStress = stress

    SendNUIMessage({
        action = 'updateStatus',
        status = {
            hunger = hunger,
            food = hunger,
            thirst = thirst,
            water = thirst,
            stress = stress
        }
    })
end)

-- Événement personnalisé pour mettre à jour ou tester les statuts
RegisterNetEvent('bl_hud_pl:client:setStatus', function(data)
    if not data then return end
    if data.hunger ~= nil or data.food ~= nil then
        CurrentHunger = math.max(0, math.min(100, sanitizeNumber(data.hunger or data.food, 100)))
    end
    if data.thirst ~= nil or data.water ~= nil then
        CurrentThirst = math.max(0, math.min(100, sanitizeNumber(data.thirst or data.water, 100)))
    end
    if data.stress ~= nil then
        CurrentStress = math.max(0, math.min(100, sanitizeNumber(data.stress, 0)))
    end

    SendNUIMessage({
        action = 'updateStatus',
        status = {
            hunger = CurrentHunger,
            food = CurrentHunger,
            thirst = CurrentThirst,
            water = CurrentThirst,
            stress = CurrentStress
        }
    })
end)

-- --- BOUCLE DE PERTE DE VIE (FAIM & SOIF À 0%) ---
CreateThread(function()
    while true do
        local sleep = 1000
        local cfg = Config.Starvation

        if cfg and cfg.enabled and GetGameTimer() > starvationGraceTime then
            local isHungerStarving = (cfg.affectHunger ~= false) and (CurrentHunger <= 0) and ((cfg.hungerDamage or 0) > 0)
            local isThirstStarving = (cfg.affectThirst ~= false) and (CurrentThirst <= 0) and ((cfg.thirstDamage or 0) > 0)

            if isHungerStarving or isThirstStarving then
                sleep = cfg.interval or 5000
                local ped = PlayerPedId()

                if DoesEntityExist(ped) and not IsEntityDead(ped) then
                    local damage = 0
                    if isHungerStarving then
                        damage = damage + (cfg.hungerDamage or 5)
                    end
                    if isThirstStarving then
                        damage = damage + (cfg.thirstDamage or 5)
                    end

                    if damage > 0 then
                        local currentHealth = GetEntityHealth(ped)
                        local maxHealth = GetEntityMaxHealth(ped)
                        -- Seuil de survie GTA V standard (100 HP si maxHealth > 100, sinon 0)
                        local minLivingHealth = (maxHealth > 100) and 100 or 0
                        local newHealth = currentHealth - damage

                        if newHealth <= minLivingHealth then
                            SetEntityHealth(ped, 0)
                        else
                            SetEntityHealth(ped, newHealth)
                        end

                        if cfg.screenEffect then
                            ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.08)
                        end
                    end
                end
            end
        end

        Wait(sleep)
    end
end)

-- Synchronisation des comptes complets
RegisterNetEvent('bl_hud_pl:client:updateAccounts', function(accounts)
    if not accounts then return end
    for accName, accMoney in pairs(accounts) do
        SendNUIMessage({
            action = 'updateAccount',
            name = accName,
            money = accMoney
        })
    end
end)

-- Synchronisation du nombre de joueurs connectés
RegisterNetEvent('bl_hud_pl:client:updatePlayersCount', function(count)
    SendNUIMessage({
        action = 'updatePlayersCount',
        count = count
    })
end)

-- Synchronisation du Ping
RegisterNetEvent('bl_hud_pl:client:updatePing', function(ping)
    SendNUIMessage({
        action = 'updateTech',
        ping = ping
    })
end)

-- Synchronisation de la Météo
RegisterNetEvent('bl_hud_pl:client:setWeather', function(weatherData)
    if weatherData then
        SendNUIMessage({
            action = 'updateWeather',
            weather = weatherData
        })
    end
end)

-- --- GESTION DE LA VOIX & RADIO ---

-- Support PMA-Voice
RegisterNetEvent('pma-voice:setTalkingMode', function(voiceMode)
    local rangeData = Config.VoiceRanges[voiceMode] or Config.VoiceRanges[2]
    SendNUIMessage({
        action = 'updateVoice',
        voice = {
            mode = voiceMode,
            distance = rangeData.distance,
            label = rangeData.label,
            percentage = rangeData.percentage
        }
    })
end)

RegisterNetEvent('pma-voice:radioActive', function(radioTalking)
    SendNUIMessage({
        action = 'updateRadio',
        active = radioTalking
    })
end)

RegisterNetEvent('pma-voice:setRadioChannel', function(channel)
    if channel and channel > 0 then
        SendNUIMessage({
            action = 'updateRadio',
            active = true,
            freq = string.format("%.1f MHz", channel)
        })
    else
        SendNUIMessage({
            action = 'updateRadio',
            active = false,
            freq = nil
        })
    end
end)

-- --- COMMANDES & TOUCHES (SETTINGS / CINÉMATIQUE) ---

function ToggleHudSettings(forceState)
    if forceState ~= nil then
        isSettingsOpen = forceState
    else
        isSettingsOpen = not isSettingsOpen
    end
    if isSettingsOpen then
        SetHUDVisibility(true)
    end
    if ResetWeaponHUDCache then
        ResetWeaponHUDCache()
    end
    if isSettingsOpen then
        -- Vérifié à chaque ouverture (le grade peut changer en cours de partie)
        TriggerServerEvent('bl_hud_pl:server:checkAdmin')
    end
    SetNuiFocus(isSettingsOpen, isSettingsOpen)
    local hasCarHud = (GetResourceState('bl_hud_car') == 'started')
    SendNUIMessage({
        action = 'toggleSettings',
        open = isSettingsOpen,
        hasCarHud = hasCarHud
    })
end

RegisterNetEvent('bl_hud_pl:client:openSettings', function()
    ToggleHudSettings(true)
end)

function ToggleCinematicMode(forceState)
    if forceState ~= nil then
        isCinematicActive = forceState
    else
        isCinematicActive = not isCinematicActive
    end
    DisplayRadar(not isCinematicActive)
    SendNUIMessage({
        action = 'toggleCinematic',
        active = isCinematicActive
    })
end

-- Maintien de la disparition forcée de la minimap en mode cinématique
CreateThread(function()
    while true do
        if isCinematicActive then
            DisplayRadar(false)
            Wait(0)
        else
            Wait(300)
        end
    end
end)

local settingsCmd = Config.SettingsCommand or "hud"
RegisterCommand(settingsCmd, function()
    ToggleHudSettings()
end, false)

if settingsCmd ~= "hud" then
    RegisterCommand("hud", function()
        ToggleHudSettings()
    end, false)
end

if settingsCmd ~= "hudconfig" then
    RegisterCommand("hudconfig", function()
        ToggleHudSettings()
    end, false)
end

if Config.SettingsKey and Config.SettingsKey ~= "" then
    RegisterKeyMapping(settingsCmd, "Menu personnalisation du HUD", "keyboard", Config.SettingsKey)
end

RegisterCommand(Config.CinematicCommand, function()
    ToggleCinematicMode()
end, false)

-- --- NUI CALLBACKS ---

RegisterNUICallback('closeSettings', function(data, cb)
    isSettingsOpen = false
    SetNuiFocus(false, false)
    if ResetWeaponHUDCache then
        ResetWeaponHUDCache()
    end
    cb('ok')
end)

RegisterNUICallback('startCarHudEdit', function(data, cb)
    isSettingsOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'toggleSettings',
        open = false
    })
    if GetResourceState('bl_hud_car') == 'started' then
        TriggerEvent('bl_hud_car:client:startEditMode', true)
    end
    cb('ok')
end)

RegisterNUICallback('toggleCinematic', function(data, cb)
    if data and data.active ~= nil then
        ToggleCinematicMode(data.active)
    else
        ToggleCinematicMode()
    end
    cb('ok')
end)

RegisterNUICallback('saveSettings', function(settings, cb)
    if Config.Debug then
        print("[BloodLeak HUD] Paramètres sauvegardés par le joueur.")
    end
    if ResetWeaponHUDCache then
        ResetWeaponHUDCache()
    end
    cb('ok')
end)

RegisterNUICallback('savePositions', function(positions, cb)
    if Config.Debug then
        print("[BloodLeak HUD] Positions sauvegardées par le joueur.")
    end
    cb('ok')
end)

RegisterNUICallback('saveServerDefaultPositions', function(positions, cb)
    TriggerServerEvent('bl_hud_pl:server:saveDefaultPositions', positions)
    cb('ok')
end)

-- Appelé par le bouton "Enregistrer sur le serveur" de l'onglet Annonces
RegisterNUICallback('saveServerAnnouncements', function(announcements, cb)
    if type(announcements) == 'table' then
        TriggerServerEvent('bl_hud_pl:server:saveAnnouncements', announcements)
    end
    cb('ok')
end)

RegisterNUICallback('nuiReady', function(data, cb)
    if ResetWeaponHUDCache then
        ResetWeaponHUDCache()
    end
    if UpdateMinimapPosition then
        UpdateMinimapPosition(true)
    end
    -- L'interface ne s'affiche plus d'elle-même sur 'initHud' : on lui renvoie l'état réel
    if isPlayerLoaded and not isHudHidden then
        SendNUIMessage({ action = 'setHudVisible', visible = true })
    end
    SendNUIMessage({
        action = 'setAnnouncements',
        announcements = GetAnnouncementsPayload()
    })
    cb('ok')
end)

RegisterCommand('hudsavedefault', function()
    SendNUIMessage({
        action = 'triggerSaveServerDefault'
    })
end, false)

-- --- EXPORTS ---

exports('SetHUDVisibility', function(visible)
    SetHUDVisibility(visible)
end)

exports('SetVisible', function(visible)
    SetHUDVisibility(visible)
end)

exports('ToggleHUD', function()
    SetHUDVisibility(isHudHidden)
end)

exports('ToggleSettings', function(forceState)
    ToggleHudSettings(forceState)
end)

exports('OpenSettings', function()
    ToggleHudSettings(true)
end)

exports('ToggleCinematic', function(forceState)
    ToggleCinematicMode(forceState)
end)

exports('IsHUDHidden', function()
    return isHudHidden
end)

