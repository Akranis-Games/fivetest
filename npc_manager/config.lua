Config = {}

-- NPC Manager Konfiguration
Config.NPCManager = {
    UpdateInterval = 5000,      -- Update-Intervall in ms
    SpawnDistance = 100,        -- Spawn-Distanz in Metern
    DespawnDistance = 200,      -- Despawn-Distanz in Metern
    MaxNPCsActive = 50,         -- Max. aktive NPCs gleichzeitig
    AnimationFPS = 30,          -- Animation FPS
}

-- Verfügbare Animationen
Config.Animations = {
    idle = 'combat@damage@rb_writhe',
    walk = 'move_m@business@a',
    talk = 'anim@mp_player_intmenu@fs_interrogation@base',
    sit = 'timetable@reunited@player_textured',
    stand_idle = 'amb@world_human_stupor@male@base',
    wave = 'anim@mp_point',
}

-- Standard NPC-Einstellungen
Config.DefaultNPC = {
    heading = 0.0,
    scale = 1.0,
    frozen = false,
    invulnerable = false,
    mission = false,
    canBeDamaged = true,
    dialogue = false,
}

-- Deutsche Sprache
Config.Locale = 'de'
Config.Locales = {
    de = {
        npc_created = '^2[NPC Manager]^7 NPC erstellt: %s',
        npc_deleted = '^2[NPC Manager]^7 NPC gelöscht: %s',
        npc_loaded = '^2[NPC Manager]^7 %d NPCs geladen',
        npc_spawned = '^2[NPC Manager]^7 NPC gespawnt: %s (%d)',
        npc_despawned = '^2[NPC Manager]^7 NPC despawnt: %s (%d)',
        invalid_model = '^1[NPC Manager]^7 Ungültiges NPC-Modell: %s',
        error_create = '^1[NPC Manager]^7 Fehler beim Erstellen: %s',
    },
}

function _U(string)
    return Config.Locales[Config.Locale][string] or string
end
