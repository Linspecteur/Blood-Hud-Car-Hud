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
end)

local ServerDefaultPositions = {}

local function LoadSavedServerPositions()
    local content = LoadResourceFile(GetCurrentResourceName(), "positions.json")
    if content and content ~= "" then
        local ok, data = pcall(json.decode, content)
        if ok and type(data) == 'table' then
            ServerDefaultPositions = data
            print("[BloodLeak HUD] Positions par défaut serveur chargées depuis positions.json.")
        end
    end
end

-- Annonces enregistrées en jeu (onglet Annonces de /hud) ; sinon celles de config.lua
local ServerAnnouncements = Config.Announcements

local function LoadSavedAnnouncements()
    local content = LoadResourceFile(GetCurrentResourceName(), "announcements.json")
    if content and content ~= "" then
        local ok, data = pcall(json.decode, content)
        if ok and type(data) == 'table' and type(data.items) == 'table' and #data.items > 0 then
            ServerAnnouncements = data
            print("[BloodLeak HUD] Annonces serveur chargées depuis announcements.json.")
        end
    end
end

CreateThread(function()
    LoadSavedServerPositions()
    LoadSavedAnnouncements()
end)

-- --- FONCTION UTILITAIRE : RÉCUPÉRATION DU NOM RP ---

local function GetPlayerRPName(src, xPlayer)
    if not xPlayer then return GetPlayerName(src) or "Joueur" end

    -- 1. Méthode ESX get('firstName') / get('lastName')
    if xPlayer.get then
        local first = xPlayer.get('firstName') or (xPlayer.variables and xPlayer.variables.firstName)
        local last = xPlayer.get('lastName') or (xPlayer.variables and xPlayer.variables.lastName)
        if first and last and first ~= "" and last ~= "" then
            return first .. " " .. last
        end
    end

    -- 2. Méthode xPlayer.getName()
    if xPlayer.getName then
        local name = xPlayer.getName()
        if name and name ~= "" and not string.find(name, "steam:") and not string.find(name, "license:") then
            return name
        end
    end

    -- 3. Requête DB SQL (compatible ESX / oxmysql / mysql-async)
    if MySQL and MySQL.query and xPlayer.identifier then
        local result = MySQL.query.await('SELECT firstname, lastname FROM users WHERE identifier = ?', { xPlayer.identifier })
        if result and result[1] and result[1].firstname and result[1].lastname then
            return result[1].firstname .. " " .. result[1].lastname
        end
    end

    -- 4. Repli sur le nom FiveM du joueur
    return GetPlayerName(src) or "Joueur"
end

-- --- SYNCHRONISATION DES DONNÉES INITIALES DU JOUEUR ---

RegisterNetEvent('bl_hud_pl:server:requestInitialData', function()
    local src = source
    if not ESX then return end

    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    local playerName = GetPlayerRPName(src, xPlayer)

    local accounts = {}
    if xPlayer.getAccount then
        local cashAccount = xPlayer.getAccount(Config.Accounts.cash)
        local bankAccount = xPlayer.getAccount(Config.Accounts.bank)
        local blackAccount = xPlayer.getAccount(Config.Accounts.black_money)

        accounts[Config.Accounts.cash] = cashAccount and cashAccount.money or (xPlayer.getMoney and xPlayer.getMoney() or 0)
        accounts[Config.Accounts.bank] = bankAccount and bankAccount.money or 0
        accounts[Config.Accounts.black_money] = blackAccount and blackAccount.money or 0
    elseif xPlayer.accounts then
        for i = 1, #xPlayer.accounts do
            local acc = xPlayer.accounts[i]
            accounts[acc.name] = acc.money
        end
    end

    -- Récupération du compte société (si disponible dans esx_addonaccount)
    local societyMoney = 0
    if xPlayer.job and xPlayer.job.name then
        local societyName = 'society_' .. xPlayer.job.name
        TriggerEvent('esx_addonaccount:getSharedAccount', societyName, function(account)
            if account and account.money then
                societyMoney = account.money
            end
        end)
    end
    accounts['society'] = societyMoney

    -- Données de Métier
    local jobData = {
        name = (xPlayer.job and xPlayer.job.name) or "unemployed",
        label = (xPlayer.job and xPlayer.job.label) or "Sans-emploi",
        grade = (xPlayer.job and xPlayer.job.grade) or 0,
        grade_label = (xPlayer.job and xPlayer.job.grade_label) or "Citoyen"
    }

    -- Envoyer les informations complètes au client
    TriggerClientEvent('bl_hud_pl:client:receiveInitialData', src, {
        id = src,
        name = playerName,
        job = jobData,
        accounts = accounts,
        playersCount = #GetPlayers(),
        ping = GetPlayerPing(src) or 20,
        defaultPositions = ServerDefaultPositions,
        announcements = ServerAnnouncements
    })
end)

-- Synchronisation de l'argent de société lors de modifications
-- Événement serveur interne d'esx_addonaccount : AddEventHandler seul (et non RegisterNetEvent)
-- pour qu'un client ne puisse pas le déclencher et afficher un faux solde société.
AddEventHandler('esx_addonaccount:setMoney', function(societyName, money)
    if not ESX or not societyName or not money then return end
    local cleanJob = string.gsub(societyName, 'society_', '')
    local xPlayers = ESX.GetExtendedPlayers and ESX.GetExtendedPlayers('job', cleanJob) or ESX.GetPlayers()

    for _, playerId in ipairs(xPlayers) do
        local targetId = type(playerId) == 'table' and playerId.source or playerId
        local xPlayer = type(playerId) == 'table' and playerId or ESX.GetPlayerFromId(targetId)
        if xPlayer and xPlayer.job and xPlayer.job.name == cleanJob then
            TriggerClientEvent('bl_hud_pl:client:updateAccount', targetId, 'society', money)
        end
    end
end)

-- --- GESTION DES POSITIONS PAR DÉFAUT DU HUD (FONDATEUR / ADMIN) ---

local function IsPlayerAdmin(src)
    if src == 0 then return true end
    if Config.AllowEveryoneToSetServerDefault then return true end

    if IsPlayerAceAllowed(src, "command") or IsPlayerAceAllowed(src, "hud.admin") or IsPlayerAceAllowed(src, "admin") then
        return true
    end

    if ESX then
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer then
            -- 1. Vérification du groupe ESX (admin, superadmin, founder, boss, etc.)
            local group = xPlayer.getGroup and xPlayer.getGroup() or xPlayer.group
            if group then
                local groupStr = string.lower(tostring(group))
                if Config.AdminGroups and Config.AdminGroups[groupStr] then
                    return true
                end
            end

            -- 2. Vérification du grade ou nom de métier / gang 'boss'
            if Config.AllowBossGrade then
                if xPlayer.job then
                    local gradeName = string.lower(tostring(xPlayer.job.grade_name or ""))
                    local gradeLabel = string.lower(tostring(xPlayer.job.grade_label or ""))
                    local jobName = string.lower(tostring(xPlayer.job.name or ""))
                    if gradeName == "boss" or gradeLabel == "boss" or jobName == "boss" then
                        return true
                    end
                end
                if xPlayer.job2 then
                    local gradeName2 = string.lower(tostring(xPlayer.job2.grade_name or ""))
                    local gradeLabel2 = string.lower(tostring(xPlayer.job2.grade_label or ""))
                    local jobName2 = string.lower(tostring(xPlayer.job2.name or ""))
                    if gradeName2 == "boss" or gradeLabel2 == "boss" or jobName2 == "boss" then
                        return true
                    end
                end
            end
        end
    end
    return false
end

RegisterNetEvent('bl_hud_pl:server:saveDefaultPositions', function(positions)
    local src = source
    if not IsPlayerAdmin(src) then
        TriggerClientEvent('chat:addMessage', src, {
            color = { 230, 33, 33 },
            multiline = true,
            args = { "HUD", "Permission refusée : réservé aux Fondateurs / Admins." }
        })
        return
    end

    if type(positions) == 'table' then
        ServerDefaultPositions = positions
        SaveResourceFile(GetCurrentResourceName(), "positions.json", json.encode(positions, { indent = true }), -1)
        print(string.format("[BloodLeak HUD] Nouvelles positions par défaut enregistrées par [%s] %s.", src, GetPlayerName(src)))

        TriggerClientEvent('chat:addMessage', src, {
            color = { 46, 204, 113 },
            multiline = true,
            args = { "HUD", "Positions par défaut enregistrées avec succès pour tout le serveur !" }
        })

        -- Diffuser instantanément à tous les joueurs connectés
        TriggerClientEvent('bl_hud_pl:client:applyServerDefaultPositions', -1, ServerDefaultPositions)
    end
end)

-- --- SAUVEGARDE DES ANNONCES PAR DÉFAUT DU SERVEUR (ADMIN) ---

-- L'onglet Annonces de /hud n'est affiché qu'aux admins
RegisterNetEvent('bl_hud_pl:server:checkAdmin', function()
    local src = source
    TriggerClientEvent('bl_hud_pl:client:setAdmin', src, IsPlayerAdmin(src))
end)

local function CleanAnnounceString(value, maxLen)
    if type(value) ~= 'string' then return nil end
    value = value:gsub('[<>]', '')
    if #value > maxLen then value = value:sub(1, maxLen) end
    return value
end

RegisterNetEvent('bl_hud_pl:server:saveAnnouncements', function(data)
    local src = source
    if not IsPlayerAdmin(src) then
        TriggerClientEvent('chat:addMessage', src, {
            color = { 230, 33, 33 },
            multiline = true,
            args = { "HUD", "Permission refusée : réservé aux Fondateurs / Admins." }
        })
        return
    end
    if type(data) ~= 'table' or type(data.items) ~= 'table' then return end

    local items = {}
    for i = 1, math.min(#data.items, 20) do
        local it = data.items[i]
        if type(it) == 'table' then
            local color = type(it.color) == 'string' and it.color:match('^#%x%x%x%x%x%x$') or '#E50914'
            local icon = CleanAnnounceString(it.icon, 64)
            if icon then icon = icon:gsub('[^%w%- ]', '') end
            items[#items + 1] = {
                tag = CleanAnnounceString(it.tag, 24) or 'INFO',
                title = CleanAnnounceString(it.title, 60) or 'ANNONCE',
                text = CleanAnnounceString(it.text, 90) or '',
                cta = CleanAnnounceString(it.cta, 16) or 'VOIR',
                icon = (icon and icon ~= '') and icon or 'fa-solid fa-bullhorn',
                color = color
            }
        end
    end
    if #items == 0 then return end

    ServerAnnouncements = {
        enabled = data.enabled ~= false,
        interval = math.max(3000, math.min(60000, tonumber(data.interval) or 8500)),
        items = items
    }
    SaveResourceFile(GetCurrentResourceName(), "announcements.json", json.encode(ServerAnnouncements, { indent = true }), -1)
    print(string.format("[BloodLeak HUD] Annonces serveur enregistrées par [%s] %s.", src, GetPlayerName(src)))

    TriggerClientEvent('chat:addMessage', src, {
        color = { 46, 204, 113 },
        multiline = true,
        args = { "HUD", "Annonces enregistrées pour tout le serveur !" }
    })
    TriggerClientEvent('bl_hud_pl:client:setAnnouncements', -1, ServerAnnouncements)
end)

-- Commande console serveur /hudsavedefault
RegisterCommand("hudsavedefault", function(source, args)
    if source == 0 then
        print("[BloodLeak HUD] Cette commande s'utilise en jeu via le bouton 'Définir par défaut (Serveur)' du menu /hudconfig.")
    end
end, true)

-- --- DIFFUSION RÉGULIÈRE DU NOMBRE DE JOUEURS EN LIGNE ---

CreateThread(function()
    while true do
        Wait(15000) -- Toutes les 15 secondes
        local playersCount = #GetPlayers()
        TriggerClientEvent('bl_hud_pl:client:updatePlayersCount', -1, playersCount)
    end
end)

-- Mise à jour immédiate lors d'une connexion / déconnexion
AddEventHandler('playerJoining', function()
    SetTimeout(1500, function()
        TriggerClientEvent('bl_hud_pl:client:updatePlayersCount', -1, #GetPlayers())
    end)
end)

AddEventHandler('playerDropped', function()
    SetTimeout(1500, function()
        TriggerClientEvent('bl_hud_pl:client:updatePlayersCount', -1, #GetPlayers())
    end)
end)
