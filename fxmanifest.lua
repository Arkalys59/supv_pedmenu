fx_version 'cerulean'
game 'gta5'
lua54 'yes'
--use_experimental_fxv2_oal 'yes'

author 'SUP2Ak'
version '1.0'

description 'simple ped menu for esx'

shared_scripts {'@es_extended/imports.lua', '_g.lua'}

client_scripts {
    "src/RMenu.lua",
    "src/menu/RageUI.lua",
    "src/menu/Menu.lua",
    "src/menu/MenuController.lua",
    "src/components/*.lua",
    "src/menu/elements/*.lua",
    "src/menu/items/*.lua",
    "src/menu/panels/*.lua",
    "src/menu/windows/*.lua",
}

client_scripts {'client/config.lua', 'client/client.lua'}
server_scripts {'server/config.lua', 'server/server.lua'}