-- Bennys Tuning System Config
-- Big Benny's Lowrider Edition V2

Config = {}

-- Tuning-Shop Einstellungen
Config.ShopLocation = {
    x = 109.5,
    y = 6627.5,
    z = 31.8,
    heading = 45.0
}

-- Fahrzeug-Modelle die getunt werden können (Lowriders & Muscle Cars)
Config.TunableVehicles = {
    'sabregt',
    'phoenix',
    'hermes',
    'faction',
    'dominator',
    'gauntlet',
    'stallion',
    'blade',
    'chino',
    'impaler',
    'dukes',
    'moonbeam',
    'dilettante',
    'picador',
    'minivan',
    'buffalo',
    'buccaneer',
    'declasse',
    'panto',
    'oracle',
    'fugitive',
    'tailgater',
    'khamelion',
}

-- Tuning-Kategorien und Preise
Config.TuningParts = {
    -- Motor/Performance
    engine = {
        label = 'Motor',
        icon = 'fa-solid fa-engine',
        color = 'danger',
        levels = {
            { level = 0, label = 'Standard Motor', price = 0, power = 100 },
            { level = 1, label = 'Tuning Motor Stufe 1', price = 5000, power = 115 },
            { level = 2, label = 'Tuning Motor Stufe 2', price = 8000, power = 130 },
            { level = 3, label = 'Tuning Motor Stufe 3', price = 12000, power = 150 },
        }
    },

    -- Bremsanlage
    brakes = {
        label = 'Bremsanlage',
        icon = 'fa-solid fa-circle',
        color = 'warning',
        levels = {
            { level = 0, label = 'Standard Bremsen', price = 0, braking = 100 },
            { level = 1, label = 'Sport Bremsen', price = 3000, braking = 115 },
            { level = 2, label = 'Performance Bremsen', price = 5000, braking = 130 },
            { level = 3, label = 'Racing Bremsen', price = 8000, braking = 150 },
        }
    },

    -- Transmission
    transmission = {
        label = 'Getriebe',
        icon = 'fa-solid fa-gears',
        color = 'info',
        levels = {
            { level = 0, label = 'Standard Getriebe', price = 0, acceleration = 100 },
            { level = 1, label = 'Tuning Getriebe', price = 4000, acceleration = 115 },
            { level = 2, label = 'Sport Getriebe', price = 7000, acceleration = 130 },
            { level = 3, label = 'Racing Getriebe', price = 10000, acceleration = 150 },
        }
    },

    -- Felgen
    wheels = {
        label = 'Felgen & Reifen',
        icon = 'fa-solid fa-tire',
        color = 'secondary',
        levels = {
            { level = 0, label = 'Standard Felgen', price = 0 },
            { level = 1, label = 'Chrome Felgen', price = 2000 },
            { level = 2, label = 'Gold Felgen', price = 3500 },
            { level = 3, label = 'Platinum Felgen', price = 5000 },
            { level = 4, label = 'Forgiato Felgen', price = 7000 },
        }
    },

    -- Fahrwerk
    suspension = {
        label = 'Fahrwerk',
        icon = 'fa-solid fa-person-hiking',
        color = 'success',
        levels = {
            { level = 0, label = 'Standard Fahrwerk', price = 0 },
            { level = 1, label = 'Tieferlegung Stufe 1', price = 3000 },
            { level = 2, label = 'Tieferlegung Stufe 2', price = 5000 },
            { level = 3, label = 'Airbag Fahrwerk', price = 8000 },
        }
    },

    -- Auspuff
    exhaust = {
        label = 'Auspuff',
        icon = 'fa-solid fa-wind',
        color = 'dark',
        levels = {
            { level = 0, label = 'Standard Auspuff', price = 0 },
            { level = 1, label = 'Sport Auspuff', price = 1500 },
            { level = 2, label = 'Performance Auspuff', price = 2500 },
            { level = 3, label = 'Custom Auspuff', price = 4000 },
        }
    },

    -- Körper-Reparatur
    armor = {
        label = 'Panzerung',
        icon = 'fa-solid fa-shield',
        color = 'primary',
        levels = {
            { level = 0, label = 'Keine Panzerung', price = 0, armor = 0 },
            { level = 1, label = 'Leichte Panzerung', price = 5000, armor = 20 },
            { level = 2, label = 'Mittlere Panzerung', price = 8000, armor = 50 },
            { level = 3, label = 'Schwere Panzerung', price = 12000, armor = 80 },
        }
    },

    -- Lackierung
    paint = {
        label = 'Lackierung',
        icon = 'fa-solid fa-palette',
        color = 'purple',
        levels = {
            { level = 0, label = 'Standard Lack', price = 0 },
            { level = 1, label = 'Candy Lack', price = 500 },
            { level = 2, label = 'Pearl Lack', price = 1000 },
            { level = 3, label = 'Matt Lack', price = 1500 },
            { level = 4, label = 'Chrome Lack', price = 2000 },
        }
    },

    -- Fenstergetönung
    windows = {
        label = 'Fenstergetönung',
        icon = 'fa-solid fa-window-minimize',
        color = 'cyan',
        levels = {
            { level = 0, label = 'Keine Getönung', price = 0 },
            { level = 1, label = 'Leichte Getönung', price = 500 },
            { level = 2, label = 'Dunkle Getönung', price = 800 },
            { level = 3, label = 'Schwarze Getönung', price = 1200 },
        }
    },

    -- Beleuchtung
    lights = {
        label = 'LED Beleuchtung',
        icon = 'fa-solid fa-lightbulb',
        color = 'warning',
        levels = {
            { level = 0, label = 'Standard Beleuchtung', price = 0 },
            { level = 1, label = 'LED Xenon', price = 2000 },
            { level = 2, label = 'RGB LED Neon', price = 4000 },
            { level = 3, label = 'Custom LED Setup', price = 6000 },
        }
    },
}

-- Tuning-Shop NPC
Config.TuningNPC = {
    model = 'a_m_m_business_1',
    x = 110.5,
    y = 6627.5,
    z = 31.8,
    heading = 45.0,
    anim = { dict = 'combat@damage@rb_writhe', clip = 'rb_writhe_loop' }
}

-- Blip-Einstellungen
Config.Blip = {
    enabled = true,
    sprite = 446,
    color = 1,
    scale = 0.8,
    label = 'Bennys Tuning'
}

-- Weitere Einstellungen
Config.DrawDistance = 50.0
Config.RefreshInterval = 100 -- ms
Config.DebugMode = false

return Config
