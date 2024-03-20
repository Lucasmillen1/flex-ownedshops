fx_version "bodacious"
game "gta5"
lua54 "yes"

author "flexiboi-edited by Lucas Millen"
description "Flex-ownedshops"
version "1.0.0"

shared_scripts {
    '@PolyZone/client.lua',
    '@PolyZone/CircleZone.lua',
    '@PolyZone/BoxZone.lua',
    'config.lua',
    '@qb-core/shared/locale.lua',
    'locales/en.lua',
    'locales/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    '@qb-phone/server/main.lua' -- Added qb-phone server script
}

client_scripts {
    'client/*.lua',
    '@qb-phone/client/main.lua' -- Added qb-phone client script
}

dependencies {
    'qb-core'
}
