-- Bennys Tuning System - Client
local ESX = nil
local CurrentVehicle = nil
local VehicleTuning = {}
local ShopBlip = nil
local InTuningZone = false

TriggerEvent('esx:getSharedObject', function(obj)
    ESX = obj
end)

-- Blip erstellen
local function CreateShopBlip()
    if Config.Blip.enabled then
        ShopBlip = AddBlipForCoord(Config.ShopLocation.x, Config.ShopLocation.y, Config.ShopLocation.z)
        SetBlipSprite(ShopBlip, Config.Blip.sprite)
        SetBlipColour(ShopBlip, Config.Blip.color)
        SetBlipScale(ShopBlip, Config.Blip.scale)
        SetBlipAsShortRange(ShopBlip, false)
        AddTextComponentString(Config.Blip.label)
        SetBlipRoute(ShopBlip, ShopBlip)
    end
end

-- NPC spawnen
local function SpawnTuningNPC()
    local npcModel = Config.TuningNPC.model
    RequestModel(GetHashKey(npcModel))
    
    while not HasModelLoaded(GetHashKey(npcModel)) do
        Wait(10)
    end

    local npc = CreatePed(4, GetHashKey(npcModel), Config.TuningNPC.x, Config.TuningNPC.y, Config.TuningNPC.z, Config.TuningNPC.heading, true, false)
    SetBlockingOfNonTemporaryEvents(npc, true)
    
    if Config.TuningNPC.anim then
        RequestAnimDict(Config.TuningNPC.anim.dict)
        while not HasAnimDictLoaded(Config.TuningNPC.anim.dict) do
            Wait(10)
        end
        TaskPlayAnim(npc, Config.TuningNPC.anim.dict, Config.TuningNPC.anim.clip, 8.0, -8.0, -1, 1, 0, false, false, false)
    end
end

-- Zone-Überprüfung
Citizen.CreateThread(function()
    while true do
        Wait(Config.RefreshInterval)

        local coords = GetEntityCoords(PlayerPedId())
        local distance = #(coords - vector3(Config.ShopLocation.x, Config.ShopLocation.y, Config.ShopLocation.z))

        if distance < Config.DrawDistance then
            if not InTuningZone then
                InTuningZone = true
            end

            if distance < 5.0 then
                TriggerScreenblurFadeIn(100)
                
                local displayText = "~INPUT_CONTEXT~ Tuning-Menü öffnen"
                BeginTextCommandDisplayHelp("STRING")
                AddTextComponentString(displayText)
                EndTextCommandDisplayHelp(0, false, true, -1)

                if IsControlJustPressed(0, 38) then -- E-Taste
                    OpenTuningMenu()
                end
            end
        else
            if InTuningZone then
                InTuningZone = false
            end
        end
    end
end)

-- Tuning-Menü öffnen
function OpenTuningMenu()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    
    if vehicle == 0 then
        TriggerEvent('ox_lib:notify', {
            type = 'error',
            description = 'Du musst in einem Fahrzeug sitzen!'
        })
        return
    end

    local model = GetEntityModel(vehicle)
    local canTune = false

    for _, v in ipairs(Config.TunableVehicles) do
        if GetHashKey(v) == model then
            canTune = true
            break
        end
    end

    if not canTune then
        TriggerEvent('ox_lib:notify', {
            type = 'error',
            description = 'Dieses Fahrzeug kann nicht getunt werden!'
        })
        return
    end

    CurrentVehicle = vehicle

    ESX.TriggerServerCallback('bennys_tuning:getVehicleTuning', function(tuning)
        VehicleTuning = tuning or {}
        BuildTuningMenu()
    end, GetVehicleNumberPlateText(vehicle))
end

-- Tuning-Menü aufbauen
function BuildTuningMenu()
    local elements = {}

    -- Überschrift
    table.insert(elements, {
        header = "🔧 BENNYS TUNING SHOP 🔧",
        isMenuHeader = true
    })

    -- Tuning-Kategorien
    for category, parts in pairs(Config.TuningParts) do
        local currentLevel = VehicleTuning[category .. '_level'] or 0
        local currentPart = parts.levels[currentLevel + 1]
        local statusText = currentPart and currentPart.label or 'Standard'

        table.insert(elements, {
            header = parts.label,
            txt = "Aktuell: " .. statusText,
            params = {
                event = 'bennys_tuning:openCategory',
                args = { category }
            }
        })
    end

    -- Verlauf
    table.insert(elements, {
        header = "📋 Tuning-Verlauf",
        txt = "Alle deine Modifikationen",
        params = {
            event = 'bennys_tuning:showHistory'
        }
    })

    -- Schließen
    table.insert(elements, {
        header = "❌ Menü schließen"
    })

    lib.registerContext({
        id = 'bennys_main_menu',
        title = 'Bennys Tuning Shop',
        options = elements,
        onClose = function()
            CurrentVehicle = nil
        end
    })

    lib.showContext('bennys_main_menu')
end

-- Kategorie-Menü öffnen
RegisterNetEvent('bennys_tuning:openCategory', function(category)
    local parts = Config.TuningParts[category]
    local currentLevel = VehicleTuning[category .. '_level'] or 0
    local elements = {}

    table.insert(elements, {
        header = parts.label,
        isMenuHeader = true
    })

    for _, part in ipairs(parts.levels) do
        local isCurrentLevel = part.level == currentLevel
        local prefix = isCurrentLevel and "✓ " or ""
        
        table.insert(elements, {
            header = prefix .. part.label,
            txt = "Preis: €" .. part.price .. " | Stufe: " .. part.level,
            params = {
                event = 'bennys_tuning:purchasePart',
                args = { category, part }
            }
        })
    end

    lib.registerContext({
        id = 'bennys_category_' .. category,
        title = parts.label,
        options = elements,
        back = 'bennys_main_menu'
    })

    lib.showContext('bennys_category_' .. category)
end)

-- Tuning-Teil kaufen
RegisterNetEvent('bennys_tuning:purchasePart', function(category, part)
    TriggerEvent('ox_lib:notify', {
        type = 'info',
        description = 'Fahrzeug wird getunt...'
    })

    TriggerServerEvent('bennys_tuning:doTuning', 
        GetVehicleNumberPlateText(CurrentVehicle), 
        category, 
        part.level, 
        part.price
    )

    Wait(1000)
    VehicleTuning[category .. '_level'] = part.level
    BuildTuningMenu()
end)

-- Tuning-Verlauf anzeigen
RegisterNetEvent('bennys_tuning:showHistory', function()
    ESX.TriggerServerCallback('bennys_tuning:getTuningHistory', function(history)
        local elements = {}

        table.insert(elements, {
            header = "📋 Dein Tuning-Verlauf",
            isMenuHeader = true
        })

        if #history == 0 then
            table.insert(elements, {
                header = "Noch keine Modifikationen",
                txt = "Komm vorbei und lass dein Auto tunen!"
            })
        else
            for _, entry in ipairs(history) do
                local date = string.sub(entry.created_at, 1, 10)
                local time = string.sub(entry.created_at, 12, 19)
                
                table.insert(elements, {
                    header = entry.part_category:upper(),
                    txt = "Stufe " .. entry.new_level .. " | €" .. entry.cost .. " | " .. date .. " " .. time
                })
            end
        end

        lib.registerContext({
            id = 'bennys_history',
            title = 'Tuning-Verlauf',
            options = elements,
            back = 'bennys_main_menu'
        })

        lib.showContext('bennys_history')
    end)
end)

-- Initialisierung beim Start
CreateThread(function()
    Wait(1000)
    CreateShopBlip()
    SpawnTuningNPC()
    print('^2[bennys_tuning]^7 Client gestartet!')
end)

-- Fahrzeug-Tuning-Status synchronisieren
RegisterNetEvent('bennys_tuning:receiveTuning', function(tuning)
    VehicleTuning = tuning or {}
end)
