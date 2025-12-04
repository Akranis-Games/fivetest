-- Bennys Tuning System - Server
local ESX = exports['es_extended']:getSharedObject()
local MySQL = exports.oxmysql
local TuningData = {}

-- Placeholders für Funktionen
local GetVehicleTuning = nil
local SaveVehicleTuning = nil
local UpdateTuningPart = nil
local GetTuningHistory = nil

CreateThread(function()
    while not MySQL do
        Wait(100)
    end
    Wait(500)
    -- Tabellen erstellen
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS vehicle_tuning (
            id INT AUTO_INCREMENT PRIMARY KEY,
            vehicle_id INT NOT NULL,
            owner_identifier VARCHAR(100) NOT NULL,
            owner_name VARCHAR(100),
            model VARCHAR(50),
            engine_level INT DEFAULT 0,
            brakes_level INT DEFAULT 0,
            transmission_level INT DEFAULT 0,
            wheels_level INT DEFAULT 0,
            suspension_level INT DEFAULT 0,
            exhaust_level INT DEFAULT 0,
            armor_level INT DEFAULT 0,
            paint_level INT DEFAULT 0,
            windows_level INT DEFAULT 0,
            lights_level INT DEFAULT 0,
            total_invested INT DEFAULT 0,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            UNIQUE KEY unique_vehicle_tuning (vehicle_id, owner_identifier)
        )
    ]], {})

    -- Tuning-Verlauf-Tabelle
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS tuning_history (
            id INT AUTO_INCREMENT PRIMARY KEY,
            vehicle_id INT NOT NULL,
            owner_identifier VARCHAR(100) NOT NULL,
            owner_name VARCHAR(100),
            part_category VARCHAR(50),
            old_level INT,
            new_level INT,
            cost INT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            INDEX idx_owner (owner_identifier),
            INDEX idx_vehicle (vehicle_id)
        )
    ]], {})

    print('^2[bennys_tuning]^7 Datenbanktabellen erstellt!')

    -- Placeholder Funktionen hier definieren
    GetVehicleTuning = function(vehicleId, identifier)
        local result = MySQL.query.await(
            'SELECT * FROM vehicle_tuning WHERE vehicle_id = ? AND owner_identifier = ?',
            { vehicleId, identifier }
        )
        return result[1] or nil
    end

    -- Tuning speichern
    SaveVehicleTuning = function(vehicleId, identifier, name, model, tuningData)
        local existing = GetVehicleTuning(vehicleId, identifier)
        
        if existing then
            return MySQL.update.await(
                'UPDATE vehicle_tuning SET engine_level = ?, brakes_level = ?, transmission_level = ?, wheels_level = ?, suspension_level = ?, exhaust_level = ?, armor_level = ?, paint_level = ?, windows_level = ?, lights_level = ?, total_invested = ?, updated_at = NOW() WHERE vehicle_id = ? AND owner_identifier = ?',
                {
                    tuningData.engine or 0,
                    tuningData.brakes or 0,
                    tuningData.transmission or 0,
                    tuningData.wheels or 0,
                    tuningData.suspension or 0,
                    tuningData.exhaust or 0,
                    tuningData.armor or 0,
                    tuningData.paint or 0,
                    tuningData.windows or 0,
                    tuningData.lights or 0,
                    tuningData.totalInvested or 0,
                    vehicleId,
                    identifier
                }
            )
        else
            return MySQL.insert.await(
                'INSERT INTO vehicle_tuning (vehicle_id, owner_identifier, owner_name, model, engine_level, brakes_level, transmission_level, wheels_level, suspension_level, exhaust_level, armor_level, paint_level, windows_level, lights_level, total_invested) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
                {
                    vehicleId,
                    identifier,
                    name,
                    model,
                    tuningData.engine or 0,
                    tuningData.brakes or 0,
                    tuningData.transmission or 0,
                    tuningData.wheels or 0,
                    tuningData.suspension or 0,
                    tuningData.exhaust or 0,
                    tuningData.armor or 0,
                    tuningData.paint or 0,
                    tuningData.windows or 0,
                    tuningData.lights or 0,
                    tuningData.totalInvested or 0
                }
            )
        end
    end

    -- Einzelner Tuning-Teil aktualisieren
    UpdateTuningPart = function(vehicleId, identifier, part, level, cost)
        MySQL.insert.await(
            'INSERT INTO tuning_history (vehicle_id, owner_identifier, owner_name, part_category, new_level, cost) SELECT ?, ?, owner_name, ?, ?, ? FROM vehicle_tuning WHERE vehicle_id = ? AND owner_identifier = ?',
            { vehicleId, identifier, part, level, cost, vehicleId, identifier }
        )

        local partColumn = part .. '_level'
        return MySQL.update.await(
            'UPDATE vehicle_tuning SET ' .. partColumn .. ' = ?, total_invested = total_invested + ? WHERE vehicle_id = ? AND owner_identifier = ?',
            { level, cost, vehicleId, identifier }
        )
    end

    -- Tuning-Verlauf abrufen
    GetTuningHistory = function(identifier, limit)
        return MySQL.query.await(
            'SELECT * FROM tuning_history WHERE owner_identifier = ? ORDER BY created_at DESC LIMIT ?',
            { identifier, limit or 50 }
        )
    end

    print('^2[bennys_tuning]^7 Modul initialisiert!')
end)

-- Server Callbacks
ESX.RegisterServerCallback('bennys_tuning:getVehicleTuning', function(source, cb, vehicleId)
    local xPlayer = ESX.GetPlayerFromId(source)
    if GetVehicleTuning then
        local tuning = GetVehicleTuning(vehicleId, xPlayer.identifier)
        cb(tuning or {})
    else
        cb({})
    end
end)

ESX.RegisterServerCallback('bennys_tuning:getTuningHistory', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if GetTuningHistory then
        local history = GetTuningHistory(xPlayer.identifier, 100)
        cb(history or {})
    else
        cb({})
    end
end)

-- Tuning durchführen
RegisterNetEvent('bennys_tuning:doTuning', function(vehicleId, tuningPart, level, cost)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer or not GetVehicleTuning or not UpdateTuningPart then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'System noch nicht bereit!'
        })
        return
    end

    if xPlayer.getMoney() < cost then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'Du hast nicht genug Geld!'
        })
        return
    end

    xPlayer.removeMoney(cost)
    
    local tuning = GetVehicleTuning(vehicleId, xPlayer.identifier)
    if tuning then
        UpdateTuningPart(vehicleId, xPlayer.identifier, tuningPart, level, cost)
    else
        SaveVehicleTuning(vehicleId, xPlayer.identifier, xPlayer.getName(), 'unknown', {
            [tuningPart] = level,
            totalInvested = cost
        })
    end

    TriggerClientEvent('ox_lib:notify', source, {
        type = 'success',
        description = 'Fahrzeug erfolgreich getunt! Kosten: €' .. cost
    })
end)

-- Tuning-Status abfragen
RegisterNetEvent('bennys_tuning:checkTuning', function(vehicleId)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    if GetVehicleTuning then
        local tuning = GetVehicleTuning(vehicleId, xPlayer.identifier)
        TriggerClientEvent('bennys_tuning:receiveTuning', source, tuning or {})
    end
end)

-- Spieler geladen
RegisterNetEvent('esx:playerLoaded', function(xPlayer)
    -- Optional: Spieler-Tuning-Daten vorinitialisieren
end)

-- Admin-Command: Tuning zurücksetzen
RegisterCommand('resettuning', function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if not xPlayer.getGroup() == 'admin' then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'Du hast keine Berechtigung!'
        })
        return
    end

    local vehicleId = tonumber(args[1])
    
    if not vehicleId then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'Verwendung: /resettuning [vehicleId]'
        })
        return
    end

    MySQL.update.await(
        'DELETE FROM vehicle_tuning WHERE vehicle_id = ?',
        { vehicleId }
    )

    TriggerClientEvent('ox_lib:notify', source, {
        type = 'success',
        description = 'Fahrzeug-Tuning wurde zurückgesetzt!'
    })
end, false)

print('^2[bennys_tuning]^7 Server gestartet!')
