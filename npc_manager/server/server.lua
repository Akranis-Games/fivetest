local ESX = exports['es_extended']:getSharedObject()
local MySQL = exports.oxmysql

-- Cached NPCs
local CachedNPCs = {}

-- Placeholder Funktionen
local GetAllNPCs = nil
local GetNPCByID = nil
local CreateNPC = nil
local UpdateNPC = nil
local DeleteNPC = nil

-- Initialize when MySQL is ready
CreateThread(function()
    while not MySQL do
        Wait(100)
    end
    Wait(500)
    -- Create tables
    MySQL.query([[CREATE TABLE IF NOT EXISTS `npcs` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `name` varchar(50) NOT NULL,
            `model` varchar(50) NOT NULL,
            `x` float NOT NULL,
            `y` float NOT NULL,
            `z` float NOT NULL,
            `heading` float DEFAULT 0.0,
            `scale` float DEFAULT 1.0,
            `frozen` tinyint(1) DEFAULT 0,
            `invulnerable` tinyint(1) DEFAULT 0,
            `animation` varchar(100) DEFAULT NULL,
            `dialogue` tinyint(1) DEFAULT 0,
            `enabled` tinyint(1) DEFAULT 1,
            `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
            `updated_at` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            PRIMARY KEY (`id`),
            KEY `enabled` (`enabled`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]], {})

        -- Get all NPCs from database
        GetAllNPCs = function()
            local result = MySQL.query.await('SELECT * FROM npcs WHERE enabled = 1')
            return result or {}
        end

    -- Create new NPC
    CreateNPC = function(name, model, x, y, z, heading, data)
        data = data or {}
        
        local npcData = {
            name = name,
            model = model,
            x = x,
            y = y,
            z = z,
            heading = heading or 0.0,
            scale = data.scale or 1.0,
            frozen = data.frozen or false,
            invulnerable = data.invulnerable or false,
            animation = data.animation or nil,
            dialogue = data.dialogue or false,
            enabled = true,
        }
        
        local result = MySQL.insert.await('INSERT INTO npcs (name, model, x, y, z, heading, scale, frozen, invulnerable, animation, dialogue, enabled) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', {
            npcData.name, npcData.model, npcData.x, npcData.y, npcData.z, npcData.heading, 
            npcData.scale, npcData.frozen and 1 or 0, npcData.invulnerable and 1 or 0, 
            npcData.animation, npcData.dialogue and 1 or 0, 1
        })
        
        if result then
            npcData.id = result
            TriggerClientEvent('npc_manager:npcCreated', -1, npcData)
            return npcData
        end
        return false
    end

    -- Update NPC
    UpdateNPC = function(id, data)
        local updateStr = {}
        local values = {}
        
        for key, value in pairs(data) do
            if key ~= 'id' then
                table.insert(updateStr, key .. ' = ?')
                table.insert(values, value)
            end
        end
        
        table.insert(values, id)
        
        if #updateStr > 0 then
            return MySQL.update.await('UPDATE npcs SET ' .. table.concat(updateStr, ', ') .. ' WHERE id = ?', values)
        end
        return false
    end

    -- Delete NPC
    DeleteNPC = function(id)
        return MySQL.update.await('UPDATE npcs SET enabled = 0 WHERE id = ?', { id })
    end

    -- Get NPC by ID
    GetNPCByID = function(id)
        local result = MySQL.query.await('SELECT * FROM npcs WHERE id = ? AND enabled = 1', { id })
        return result and result[1] or nil
    end

    -- Load all NPCs on startup
    local npcs = GetAllNPCs()
    print('NPCs geladen: ' .. #npcs)
    CachedNPCs = npcs
    TriggerClientEvent('npc_manager:loadNPCs', -1, npcs)

    print('^2[npc_manager]^7 Modul initialisiert!')
end)

-- Server Callbacks (OUTSIDE MySQL.ready)
ESX.RegisterServerCallback('npc_manager:getAllNPCs', function(source, cb)
    if GetAllNPCs then
        local npcs = GetAllNPCs()
        cb(npcs)
    else
        cb({})
    end
end)

ESX.RegisterServerCallback('npc_manager:getNPCByID', function(source, cb, id)
    if GetNPCByID then
        local npc = GetNPCByID(id)
        cb(npc)
    else
        cb(nil)
    end
end)

-- Event Handlers (OUTSIDE MySQL.ready)
RegisterNetEvent('npc_manager:createNPC')
AddEventHandler('npc_manager:createNPC', function(name, model, x, y, z, heading, data)
    if not ESX.IsPlayerAdmin(source) or not CreateNPC then return end
    
    local npc = CreateNPC(name, model, x, y, z, heading, data)
    if npc then
        TriggerClientEvent('esx:showNotification', source, 'NPC erstellt: ' .. name)
    else
        TriggerClientEvent('esx:showNotification', source, 'Fehler beim erstellen von ' .. name)
    end
end)

RegisterNetEvent('npc_manager:updateNPC')
AddEventHandler('npc_manager:updateNPC', function(id, data)
    if not ESX.IsPlayerAdmin(source) or not UpdateNPC then return end
    
    UpdateNPC(id, data)
    TriggerClientEvent('npc_manager:npcUpdated', -1, id, data)
end)

RegisterNetEvent('npc_manager:deleteNPC')
AddEventHandler('npc_manager:deleteNPC', function(id)
    if not ESX.IsPlayerAdmin(source) or not DeleteNPC then return end
    
    DeleteNPC(id)
    TriggerClientEvent('npc_manager:npcDeleted', -1, id)
end)

-- Commands (OUTSIDE MySQL.ready)
TriggerEvent('chat:addSuggestion', '/addnpc', 'NPC hinzufügen', {
    { name = 'Name', help = 'NPC Name' },
    { name = 'Model', help = 'Ped Model' },
    { name = 'X, Y, Z, Heading', help = 'Koordinaten und Heading' }
})

RegisterCommand('addnpc', function(source, args, rawCommand)
    if not ESX.IsPlayerAdmin(source) or not CreateNPC then
        TriggerClientEvent('esx:showNotification', source, 'Du bist kein Admin')
        return
    end
    
    if #args < 6 then
        TriggerClientEvent('esx:showNotification', source, 'Verwendung: /addnpc [Name] [Model] [X] [Y] [Z] [Heading]')
        return
    end
    
    local name = args[1]
    local model = args[2]
    local x, y, z, heading = tonumber(args[3]), tonumber(args[4]), tonumber(args[5]), tonumber(args[6]) or 0.0
    
    CreateNPC(name, model, x, y, z, heading)
end, false)

RegisterCommand('delnpc', function(source, args, rawCommand)
    if not ESX.IsPlayerAdmin(source) or not DeleteNPC then
        TriggerClientEvent('esx:showNotification', source, 'Du bist kein Admin')
        return
    end
    
    if #args < 1 then
        TriggerClientEvent('esx:showNotification', source, 'Verwendung: /delnpc [ID]')
        return
    end
    
    local id = tonumber(args[1])
    DeleteNPC(id)
    TriggerClientEvent('esx:showNotification', source, 'NPC gelöscht')
end, false)

RegisterCommand('npclist', function(source, args, rawCommand)
    if not ESX.IsPlayerAdmin(source) or not GetAllNPCs then
        TriggerClientEvent('esx:showNotification', source, 'Du bist kein Admin')
        return
    end
    
    local npcs = GetAllNPCs()
    TriggerClientEvent('esx:showNotification', source, 'NPCs geladen: ' .. #npcs)
    for _, npc in ipairs(npcs) do
        print(string.format('ID: %d | Name: %s | Model: %s | Pos: %.2f, %.2f, %.2f', npc.id, npc.name, npc.model, npc.x, npc.y, npc.z))
    end
end, false)
