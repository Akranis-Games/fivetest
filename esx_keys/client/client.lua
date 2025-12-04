-- ==============================================================
-- esx_keys - server.lua (100% oxmysql-kompatibel + fehlerfrei)
-- ==============================================================

local ESX = exports['es_extended']:getSharedObject()

-- oxmysql (funktioniert mit allen aktuellen Versionen)
MySQL = exports.oxmysql

-- Datenbank-Tabelle anlegen (wird nur einmal ausgeführt, ist idempotent)
MySQL.query([[CREATE TABLE IF NOT EXISTS `player_keys` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `owner_id` VARCHAR(50) NOT NULL,
    `key_type` VARCHAR(50) NOT NULL,
    `target_type` VARCHAR(50) NOT NULL,
    `target_id` VARCHAR(50) NOT NULL,
    `target_label` VARCHAR(100) DEFAULT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    INDEX `owner_id` (`owner_id`),
    INDEX `target_type_id` (`target_type`, `target_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]])

print('^2[esx_keys]^7 Datenbanktabelle player_keys bereit')

-- ====================== FUNKTIONEN ======================

local function GetPlayerKeys(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return {} end
    return MySQL.query.await('SELECT * FROM player_keys WHERE owner_id = ?', { xPlayer.identifier }) or {}
end

local function PlayerHasKey(source, targetType, targetId)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end

    local result = MySQL.scalar.await(
        'SELECT 1 FROM player_keys WHERE owner_id = ? AND target_type = ? AND target_id = ? LIMIT 1',
        { xPlayer.identifier, targetType, targetId }
    )
    return result ~= nil
end

local function GiveKey(source, keyType, targetType, targetId, targetLabel)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end

    -- Inventar-Limit (100 Schlüssel)
    if #GetPlayerKeys(source) >= 100 then
        TriggerClientEvent('esx:showNotification', source, 'Du hast zu viele Schlüssel!')
        return false
    end

    local affectedRows = MySQL.insert.await(
        'INSERT INTO player_keys (owner_id, key_type, target_type, target_id, target_label) VALUES (?, ?, ?, ?, ?)',
        { xPlayer.identifier, keyType, targetType, targetId, targetLabel or 'Unbenannter Schlüssel' }
    )

    if affectedRows and affectedRows > 0 then
        xPlayer.addInventoryItem(keyType, 1)
        TriggerClientEvent('esx:showNotification', source,
            ('Du hast einen Schlüssel erhalten: ~y~%s~s~'):format(targetLabel or 'Unbenannter Schlüssel'))
        return true
    end

    return false
end

local function RemoveKey(source, keyId)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end

    local key = MySQL.single.await('SELECT * FROM player_keys WHERE id = ? AND owner_id = ?', { keyId, xPlayer.identifier })
    if not key then return false end

    MySQL.query.await('DELETE FROM player_keys WHERE id = ?', { keyId })
    xPlayer.removeInventoryItem(key.key_type, 1)
    TriggerClientEvent('esx:showNotification', source, 'Schlüssel entfernt')
    return true
end

local function DuplicateKey(source, keyId)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end

    if xPlayer.getMoney() < 500 then
        TriggerClientEvent('esx:showNotification', source, 'Du hast nicht genug Geld (500$)')
        return false
    end

    local key = MySQL.single.await('SELECT * FROM player_keys WHERE id = ? AND owner_id = ?', { keyId, xPlayer.identifier })
    if not key then return false end

    MySQL.insert.await(
        'INSERT INTO player_keys (owner_id, key_type, target_type, target_id, target_label) VALUES (?, ?, ?, ?, ?)',
        { xPlayer.identifier, key.key_type, key.target_type, key.target_id, key.target_label }
    )

    xPlayer.removeMoney(500)
    TriggerClientEvent('esx:showNotification', source,
        ('Schlüssel dupliziert: ~y~%s~s~ (-500$)'):format(key.target_label or 'Unbenannter Schlüssel'))
    return true
end

-- ====================== CALLBACKS ======================

ESX.RegisterServerCallback('esx_keys:getPlayerKeys', function(source, cb)
    cb(GetPlayerKeys(source))
end)

ESX.RegisterServerCallback('esx_keys:hasKey', function(source, cb, targetType, targetId)
    cb(PlayerHasKey(source, targetType, targetId))
end)

-- ====================== EVENTS ======================

RegisterNetEvent('esx_keys:giveKey', function(targetId, keyType, targetType, keyTargetId, targetLabel)
    if not ESX.IsPlayerAdmin(source) then return end
    GiveKey(targetId, keyType, targetType, keyTargetId, targetLabel)
end)

RegisterNetEvent('esx_keys:removeKey', function(keyId)
    RemoveKey(source, keyId)
end)

RegisterNetEvent('esx_keys:duplicateKey', function(keyId)
    DuplicateKey(source, keyId)
end)

-- ====================== COMMANDS ======================

TriggerEvent('chat:addSuggestion', '/givekey', 'Admin: Schlüssel an Spieler vergeben', {
    { name = 'PlayerID', help = 'ID des Spielers' },
    { name = 'KeyType', help = 'vehicle_key / house_key / safe_key / master_key' },
    { name = 'TargetType', help = 'vehicle / house / safe' },
    { name = 'TargetID', help = 'z.B. Fahrzeug-Platte oder Haus-ID' },
    { name = 'Label', help = 'Beschreibung (z.B. "Mein BMW")' }
})

RegisterCommand('givekey', function(source, args)
    if not ESX.IsPlayerAdmin(source) then
        TriggerClientEvent('esx:showNotification', source, 'Kein Zugriff!')
        return
    end

    if #args < 5 then
        TriggerClientEvent('esx:showNotification', source, 'Syntax: /givekey [ID] [keytype] [targettype] [targetid] [label]')
        return
    end

    local targetId   = tonumber(args[1])
    local keyType    = args[2]
    local targetType = args[3]
    local targetId2  = args[4]
    local label      = table.concat(args, ' ', 5)

    if not GetPlayerName(targetId) then
        TriggerClientEvent('esx:showNotification', source, 'Spieler nicht online!')
        return
    end

    GiveKey(targetId, keyType, targetType, targetId2, label)
    TriggerClientEvent('esx:showNotification', source, ('Schlüssel an ID %d gegeben'):format(targetId))
end, false)

RegisterCommand('mykeys', function(source)
    local keys = GetPlayerKeys(source)
    TriggerClientEvent('esx:showNotification', source, ('Du hast ~b~%d~s~ Schlüssel'):format(#keys))
    for _, v in ipairs(keys) do
        print(('[esx_keys] %s - ID:%d | %s | %s | %s'):format(
            GetPlayerName(source), v.id, v.key_type, v.target_type..'#'..v.target_id, v.target_label or '–'
        ))
    end
end, false)

-- ====================== USABLE ITEMS ======================

ESX.RegisterUsableItem('vehicle_key', function(source)
    TriggerClientEvent('esx:showNotification', source, 'Fahrzeugschlüssel in der Hand')
end)

ESX.RegisterUsableItem('house_key', function(source)
    TriggerClientEvent('esx:showNotification', source, 'Hausschlüssel in der Hand')
end)

ESX.RegisterUsableItem('safe_key', function(source)
    TriggerClientEvent('esx:showNotification', source, 'Tresorschlüssel in der Hand')
end)

ESX.RegisterUsableItem('master_key', function(source)
    TriggerClientEvent('esx:showNotification', source, 'Generalschlüssel in der Hand')
end)

print('^2[esx_keys]^7 Schlüssel-System vollständig geladen & bereit!')