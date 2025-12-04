-- ==============================================================
-- esx_keys - server.lua | 100% oxmysql 3.0+ kompatibel (Dez 2025)
-- ==============================================================

local ESX = exports['es_extended']:getSharedObject()
local MySQL = exports.oxmysql

-- ==============================================================
-- SCHEMA – funktioniert mit allen oxmysql-Versionen
-- ==============================================================
MySQL.prepare.await([[
    CREATE TABLE IF NOT EXISTS `player_keys` (
        `id`            INT(11)        NOT NULL AUTO_INCREMENT,
        `owner_id`      VARCHAR(50)    NOT NULL,
        `key_type`      VARCHAR(50)    NOT NULL,
        `target_type`   VARCHAR(50)    NOT NULL,
        `target_id`     VARCHAR(50)    NOT NULL,
        `target_label`  VARCHAR(100)   DEFAULT NULL,
        `created_at`    TIMESTAMP      DEFAULT CURRENT_TIMESTAMP,
        `updated_at`    TIMESTAMP      DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        PRIMARY KEY (`id`),
        INDEX `idx_owner` (`owner_id`),
        INDEX `idx_target` (`target_type`, `target_id`),
        UNIQUE KEY `unique_key` (`owner_id`, `key_type`, `target_type`, `target_id`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
]], {})

print('^2[esx_keys] Tabelle `player_keys` erfolgreich geladen/erstellt^7 (oxmysql 3.0+)')

-- ==============================================================
-- FUNKTIONEN (3.0+ kompatibel: Keine key[1] Indizierung!)
-- ==============================================================

local function GetPlayerKeys(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return {} end
    return MySQL.prepare.await('SELECT * FROM player_keys WHERE owner_id = ? ORDER BY created_at DESC', { xPlayer.identifier }) or {}
end

local function PlayerHasKey(source, targetType, targetId)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end
    local result = MySQL.prepare.await('SELECT 1 FROM player_keys WHERE owner_id = ? AND target_type = ? AND target_id = ? LIMIT 1',
        { xPlayer.identifier, targetType, targetId })
    return result ~= nil
end

local function GiveKey(source, keyType, targetType, targetId, targetLabel)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end

    if #GetPlayerKeys(source) >= 100 then
        TriggerClientEvent('esx:showNotification', source, 'Du hast zu viele Schlüssel (Max. 100)')
        return false
    end

    local affected = MySQL.prepare.await([[
        INSERT INTO player_keys (owner_id, key_type, target_type, target_id, target_label)
        VALUES (?, ?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE target_label = VALUES(target_label)
    ]], { xPlayer.identifier, keyType, targetType, targetId, targetLabel or 'Schlüssel' })

    if affected and affected > 0 then
        xPlayer.addInventoryItem(keyType, 1)
        TriggerClientEvent('esx:showNotification', source, ('Schlüssel erhalten: ~g~%s~s~'):format(targetLabel or keyType))
        return true
    end
    return false
end

local function RemoveKey(source, keyId)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end

    local key = MySQL.prepare.await('SELECT * FROM player_keys WHERE id = ? AND owner_id = ?', { keyId, xPlayer.identifier })
    if not key then return false end  -- 3.0+: key ist direkt das Objekt

    MySQL.prepare.await('DELETE FROM player_keys WHERE id = ?', { keyId })
    xPlayer.removeInventoryItem(key.key_type, 1)
    TriggerClientEvent('esx:showNotification', source, '~r~Schlüssel entfernt~s~')
    return true
end

local function DuplicateKey(source, keyId)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end

    if xPlayer.getMoney() < 500 then
        TriggerClientEvent('esx:showNotification', source, '~r~Nicht genug Geld (500$ benötigt)~s~')
        return false
    end

    local key = MySQL.prepare.await('SELECT * FROM player_keys WHERE id = ? AND owner_id = ?', { keyId, xPlayer.identifier })
    if not key then return false end  -- 3.0+: key ist direkt das Objekt

    MySQL.prepare.await([[
        INSERT INTO player_keys (owner_id, key_type, target_type, target_id, target_label)
        VALUES (?, ?, ?, ?, ?)
    ]], { xPlayer.identifier, key.key_type, key.target_type, key.target_id, key.target_label })

    xPlayer.removeMoney(500)
    xPlayer.addInventoryItem(key.key_type, 1)
    TriggerClientEvent('esx:showNotification', source, ('Schlüssel dupliziert: ~g~%s~s~ (-500$)'):format(key.target_label or key.key_type))
    return true
end

-- ==============================================================
-- CALLBACKS & EVENTS (unverändert)
-- ==============================================================

ESX.RegisterServerCallback('esx_keys:getPlayerKeys', function(source, cb)
    cb(GetPlayerKeys(source))
end)

ESX.RegisterServerCallback('esx_keys:hasKey', function(source, cb, targetType, targetId)
    cb(PlayerHasKey(source, targetType, targetId))
end)

RegisterNetEvent('esx_keys:giveKey', function(targetId, keyType, targetType, targetId2, label)
    if not ESX.IsPlayerAdmin(source) then return end
    GiveKey(targetId, keyType, targetType, targetId2, label)
end)

RegisterNetEvent('esx_keys:removeKey', function(keyId)
    RemoveKey(source, keyId)
end)

RegisterNetEvent('esx_keys:duplicateKey', function(keyId)
    DuplicateKey(source, keyId)
end)

-- ==============================================================
-- COMMANDS & USABLE ITEMS (unverändert)
-- ==============================================================

RegisterCommand('givekey', function(source, args)
    if not ESX.IsPlayerAdmin(source) then TriggerClientEvent('esx:showNotification', source, '~r~Kein Zugriff') return end
    if #args < 5 then TriggerClientEvent('esx:showNotification', source, '~o~/givekey [id] [keytype] [targettype] [targetid] [label]') return end

    local target = tonumber(args[1])
    if not GetPlayerName(target) then TriggerClientEvent('esx:showNotification', source, '~r~Spieler nicht online') return end

    GiveKey(target, args[2], args[3], args[4], table.concat(args, ' ', 5))
    TriggerClientEvent('esx:showNotification', source, ('Schlüssel an ID %d gegeben'):format(target))
end, false)

RegisterCommand('mykeys', function(source)
    TriggerClientEvent('esx:showNotification', source, ('Du hast ~b~%d~s~ Schlüssel'):format(#GetPlayerKeys(source)))
end, false)

ESX.RegisterUsableItem('vehicle_key', function(source) TriggerClientEvent('esx:showNotification', source, 'Fahrzeugschlüssel bereit') end)
ESX.RegisterUsableItem('house_key',   function(source) TriggerClientEvent('esx:showNotification', source, 'Hausschlüssel bereit') end)
ESX.RegisterUsableItem('safe_key',    function(source) TriggerClientEvent('esx:showNotification', source, 'Tresorschlüssel bereit') end)
ESX.RegisterUsableItem('master_key',  function(source) TriggerClientEvent('esx:showNotification', source, 'Generalschlüssel bereit') end)

print('^2[esx_keys] Schlüssel-System vollständig geladen – 100% oxmysql 3.0+ kompatibel!^7')
