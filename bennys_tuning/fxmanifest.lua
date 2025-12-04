fx_version 'cerulean'
game 'gta5'

author 'EXO Roleplay'
description 'Mega Tuning System für Big Benny\'s Lowrider Edition V2'
version '1.0.0'

lua54 'yes'

shared_scripts {
    'config.lua'
}

client_scripts {
    'client/client.lua'
}

server_scripts {
    'server/server.lua'
}

dependencies {
    'es_extended',
    'oxmysql'
}
