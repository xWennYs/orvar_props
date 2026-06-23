fx_version 'cerulean'
game 'gta5'

name 'orvar_props'
author 'Orvar'
description 'Static prop placer (client-only) with ox_lib points streaming'
version '2.0.0'

dependency 'ox_lib'

shared_scripts {
    '@ox_lib/init.lua'
}

server_scripts {
    'server.lua'
}

client_scripts {
    'config.lua',
    'client.lua'
}
