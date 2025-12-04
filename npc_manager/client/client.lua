local ESX = exports['es_extended']:getSharedObject()

local SpawnedNPCs = {}
local PlayerNearbyNPCs = {}

-- Load NPC model
local function LoadNPCModel(model)
    if type(model) == 'string' then
        model = GetHashKey(model)
    end
    
    RequestModel(model)
    local timeout = GetGameTimer() + 5000
    
    while not HasModelLoaded(model) and GetGameTimer() < timeout do
        Wait(10)
    end
    
    return HasModelLoaded(model)
end

-- Create NPC entity
local function CreateNPCEntity(npcData)
    if not LoadNPCModel(npcData.model) then
        print(string.format('^1[NPC Manager]^7 Fehler beim Laden des Modells: %s', npcData.model))
        return nil
    end
    
    local model = GetHashKey(npcData.model)
    local npc = CreatePed(4, model, npcData.x, npcData.y, npcData.z, npcData.heading, true, false)
    
    if npc then
        -- Entity einstellen
        SetEntityAsMissionEntity(npc, true, true)
        SetEntityHeading(npc, npcData.heading)
        SetEntityRotation(npc, 0.0, 0.0, npcData.heading, 0, true)
        SetBlockingOfNonTemporaryEvents(npc, true)
        
        -- Model freigeben
        ReleaseModelRequest(model)
        
        -- Eigenschaften anwenden
        if npcData.frozen then
            FreezeEntityPosition(npc, true)
        end
        
        if npcData.invulnerable then
            SetEntityInvincible(npc, true)
        end
        
        -- Animation laden und abspielen
        if npcData.animation then
            TaskStartScenarioInPlace(npc, npcData.animation, 0, true)
        else
            TaskStartScenarioInPlace(npc, 'WORLD_HUMAN_STUPOR', 0, true)
        end
        
        SpawnedNPCs[npcData.id] = {
            entity = npc,
            data = npcData,
            spawned = true,
        }
        
        print(string.format(_U('npc_spawned'), npcData.name, npcData.id))
        return npc
    end
    
    ReleaseModelRequest(model)
    return nil
end

-- Despawn NPC
local function DespawnNPC(id)
    if SpawnedNPCs[id] then
        local ped = SpawnedNPCs[id].entity
        if DoesEntityExist(ped) then
            DeleteEntity(ped)
        end
        SpawnedNPCs[id] = nil
        print(string.format(_U('npc_despawned'), SpawnedNPCs[id].data.name, id))
    end
end

-- Load all NPCs on client startup
RegisterNetEvent('npc_manager:loadNPCs')
AddEventHandler('npc_manager:loadNPCs', function(npcs)
    for _, npcData in ipairs(npcs) do
        CreateNPCEntity(npcData)
    end
end)

-- Create new NPC
RegisterNetEvent('npc_manager:npcCreated')
AddEventHandler('npc_manager:npcCreated', function(npcData)
    CreateNPCEntity(npcData)
end)

-- Update NPC
RegisterNetEvent('npc_manager:npcUpdated')
AddEventHandler('npc_manager:npcUpdated', function(id, data)
    if SpawnedNPCs[id] then
        SpawnedNPCs[id].data = data
        -- Re-spawn wenn Eigenschaften sich ändern
        DespawnNPC(id)
        CreateNPCEntity(data)
    end
end)

-- Delete NPC
RegisterNetEvent('npc_manager:npcDeleted')
AddEventHandler('npc_manager:npcDeleted', function(id)
    DespawnNPC(id)
end)

-- NPC Management Loop
Citizen.CreateThread(function()
    while true do
        Wait(Config.NPCManager.UpdateInterval)
        
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        
        for id, npcInfo in pairs(SpawnedNPCs) do
            local npcCoords = GetEntityCoords(npcInfo.entity)
            local distance = #(playerCoords - npcCoords)
            
            -- NPC Aktivitäten basierend auf Nähe
            if distance < 50.0 then
                -- Spieler schaut NPC an
                if IsEntityVisible(npcInfo.entity) then
                    -- NPC kann reagieren
                    if not npcInfo.data.frozen then
                        -- Idle animation spielen wenn keine andere läuft
                        if not IsEntityPlayingAnim(npcInfo.entity, 'anim@mp_player_intmenu@fs_interrogation@base', 'fs_hi', 3) then
                            TaskStartScenarioInPlace(npcInfo.entity, npcInfo.data.animation or 'WORLD_HUMAN_STUPOR', 0, true)
                        end
                    end
                end
            end
        end
    end
end)

-- Exports
exports('GetSpawnedNPCs', function()
    return SpawnedNPCs
end)

exports('GetNPCEntity', function(id)
    if SpawnedNPCs[id] then
        return SpawnedNPCs[id].entity
    end
    return nil
end)

exports('SetNPCAnimation', function(id, animation)
    if SpawnedNPCs[id] then
        TaskStartScenarioInPlace(SpawnedNPCs[id].entity, animation, 0, true)
    end
end)
