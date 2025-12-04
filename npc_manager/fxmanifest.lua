fx_version 'cerulean'
game 'gta5'

author 'State 4 Live'
description 'Zentrale NPC-Verwaltung aus Datenbank'
version '1.0.0'

dependencies {
    'es_extended',
    'oxmysql'
}

shared_scripts {
    'config.lua',
}

server_scripts {
    'server/server.lua',
}

client_scripts {
    'client/client.lua',
}
