fx_version 'bodacious'
game 'gta5'

author 'Randolio'

shared_scripts {
    '@ox_lib/init.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'bridge/server/**.lua',
    'sv_dropped.lua',
    'sv_config.lua',
}

client_scripts {
    'bridge/client/**.lua',
    'cl_dropped.lua',
}

lua54 'yes'