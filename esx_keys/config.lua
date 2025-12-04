Config = {}

-- Keys System Konfiguration
Config.Keys = {
    MaxKeysPerPlayer = 50,      -- Max. Schlüssel pro Spieler
    MaxKeysPerVehicle = 5,      -- Max. Schlüssel pro Fahrzeug
    DuplicatePrice = 500,       -- Preis für Schlüssel kopieren
    DeleteKeyPrice = 100,       -- Preis für Schlüssel löschen
}

-- Schlüssel-Typen
Config.KeyTypes = {
    vehicle_key = {
        label = 'Fahrzeugschlüssel',
        weight = 10,
        icon = 'key',
        color = '#00FFFF',
    },
    house_key = {
        label = 'Hausschlüssel',
        weight = 8,
        icon = 'home',
        color = '#FFD700',
    },
    safe_key = {
        label = 'Tresor Schlüssel',
        weight = 5,
        icon = 'lock',
        color = '#FF6347',
    },
    master_key = {
        label = 'Master Schlüssel',
        weight = 5,
        icon = 'crown',
        color = '#00FF00',
    },
}

-- Item-Definition für Inventar
Config.Items = {
    vehicle_key = {
        label = 'Fahrzeugschlüssel',
        weight = 10,
        type = 'item',
        image = 'key.png',
        unique = false,
        usable = true,
        shouldClose = true,
        dropped = true,
    },
    house_key = {
        label = 'Hausschlüssel',
        weight = 8,
        type = 'item',
        image = 'key.png',
        unique = false,
        usable = true,
        shouldClose = true,
        dropped = true,
    },
    safe_key = {
        label = 'Tresor Schlüssel',
        weight = 5,
        type = 'item',
        image = 'key.png',
        unique = false,
        usable = true,
        shouldClose = true,
        dropped = true,
    },
    master_key = {
        label = 'Master Schlüssel',
        weight = 5,
        type = 'item',
        image = 'key.png',
        unique = false,
        usable = true,
        shouldClose = true,
        dropped = true,
    },
}

-- Deutsche Sprache
Config.Locale = 'de'
Config.Locales = {
    de = {
        key_given = '^2[Keys]^7 Du hast einen Schlüssel erhalten: %s',
        key_removed = '^2[Keys]^7 Schlüssel entfernt: %s',
        key_duplicated = '^2[Keys]^7 Schlüssel kopiert: %s',
        vehicle_unlocked = '^2[Keys]^7 Fahrzeug entsperrt',
        vehicle_locked = '^2[Keys]^7 Fahrzeug gesperrt',
        house_unlocked = '^2[Keys]^7 Haus entsperrt',
        house_locked = '^2[Keys]^7 Haus gesperrt',
        no_key = '^1[Keys]^7 Du hast keinen Schlüssel dafür',
        not_owner = '^1[Keys]^7 Du bist nicht der Besitzer',
        master_key = '^2[Keys]^7 Master Schlüssel aktiv',
        insufficient_funds = '^1[Keys]^7 Nicht genug Geld',
        max_keys_reached = '^1[Keys]^7 Du kannst nicht mehr Schlüssel tragen',
        key_error = '^1[Keys]^7 Fehler beim Verwalten des Schlüssels',
    },
}

function _U(string)
    return Config.Locales[Config.Locale][string] or string
end
