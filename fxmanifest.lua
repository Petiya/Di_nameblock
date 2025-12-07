fx_version 'cerulean'
game 'gta5'

name 'Di_nameblock'
author 'Di Devoloper'
version '1.0.0'
lua54 'yes'

shared_scripts {
    'config.lua'
}

server_scripts {
    'server.lua'
}

-- let config.lua remain editable
escrow_ignore {
    'config.lua'
}
