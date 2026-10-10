fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'BloodLeak'
description 'BloodLeak v2 - Player HUD (RP Info Bar, Dynamic Gauges, Compass & Settings)'
version '2.0.0'

ui_page 'html/index.html'

files {
    'html/index.html',
    'positions.json'
}

client_scripts {
    'config.lua',
    'client/events.lua',
    'client/main.lua'
}

server_scripts {
    'config.lua',
    'server/main.lua'
}
