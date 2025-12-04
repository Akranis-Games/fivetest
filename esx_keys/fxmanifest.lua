fx_version 'cerulean'
games { 'gta5' }

author 'ShadowDev / Community'
description 'ESX Schlüssel-System – vehicle_key, house_key, safe_key, master_key'
version '2.5.0'

lua54 'yes'
use_fxv2_oal 'yes'

shared_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua' -- optional, nur wenn du ox_lib nutzt
}

server_scripts {
    'server/server.lua'
}

client_scripts {
    'client/client.lua'
}

dependencies {
    'es_extended',
    'oxmysql' -- reicht 100% aus – keine lib/MySQL.lua mehr nötig!
}

exports {
    'HasKey' -- falls andere Ressourcen den Client-Export brauchen
}