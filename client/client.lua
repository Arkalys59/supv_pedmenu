local cfg <const> = Config
local playerId <const> = PlayerId
local RequestModel <const> = RequestModel
local HasModelLoaded <const> = HasModelLoaded
local SetPlayerModel <const> = SetPlayerModel
local SetModelAsNoLongerNeeded <const> = SetModelAsNoLongerNeeded
local RegisterCommand <const> = RegisterCommand
local HasNamedPtfxAssetLoaded <const> = HasNamedPtfxAssetLoaded
local RequestNamedPtfxAsset <const> = RequestNamedPtfxAsset
local GetEntityCoords <const> = GetEntityCoords
local PlayerPedId <const> = PlayerPedId
local UseParticleFxAssetNextCall <const> = UseParticleFxAssetNextCall
local SetParticleFxNonLoopedColour <const> = SetParticleFxNonLoopedColour
local StartNetworkedParticleFxNonLoopedAtCoord <const> = StartNetworkedParticleFxNonLoopedAtCoord
local RemoveNamedPtfxAsset <const> = RemoveNamedPtfxAsset
local SetEntityCoords <const> = SetEntityCoords

local playerCoords, newCoords

local function setParticle()
    if not HasNamedPtfxAssetLoaded(cfg.Ptfx.asset[1]) then
        RequestNamedPtfxAsset(cfg.Ptfx.asset[1])
        while not HasNamedPtfxAssetLoaded(cfg.Ptfx.asset[1]) do
            Wait(10)
        end
    end
    playerCoords = GetEntityCoords(PlayerPedId(), true)
    UseParticleFxAssetNextCall(cfg.Ptfx.asset[1]) -- Prepare the Particle FX for the next upcomming Particle FX call
    SetParticleFxNonLoopedColour(cfg.Ptfx.color[1], cfg.Ptfx.color[2], cfg.Ptfx.color[3]) -- Setting the color to Red (R, G, B)
    StartNetworkedParticleFxNonLoopedAtCoord(cfg.Ptfx.asset[2], playerCoords.xyz, 2.0, 0.0, 0.0, 1.0, false, false, false, false) -- Start the animation itself
    RemoveNamedPtfxAsset(cfg.Ptfx.asset[1]) -- Clean up
end

local function set(model, key)
    if cfg.Ptfx.enable then
        setParticle()
    end
    if model then
        RequestModel(model)
        while not HasModelLoaded(model) do
            Wait(50)
        end
        SetPlayerModel(playerId(), model)
        SetModelAsNoLongerNeeded(model)
        if key == 'Animals' then
            playerCoords = GetEntityCoords(PlayerPedId())
            newCoords = vec3(playerCoords.x, playerCoords.y, playerCoords.z+1)
            SetEntityCoords(PlayerPedId(), newCoords.xyz, false, false, false, false)
        end
        return
    end
    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
        local isMale = skin.sex == 0

        TriggerEvent('skinchanger:loadDefaultModel', isMale, function()
            ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
                TriggerEvent('skinchanger:loadSkin', skin)
            end)
        end)
    end)
end

local menu, isOpen, key, desc = {}, false

local function CreateMenu()
    menu.main = RageUI.CreateMenu('PedMenu', 'Séléction')
    menu.main.Closed = function()
        isOpen = false
    end
    for k in pairs(cfg.Ped) do
        menu[k] = RageUI.CreateSubMenu(menu.main, k, cfg.Cat[k] or k)
    end
    for _,v in pairs(menu) do
        v:SetRectangleBanner(0,0,230,100)
        v:DisplayGlare(true)
        v.TitleFont = 0
    end
end

local function OpenPedMenu()
    CreateMenu()
    RageUI.Visible(menu.main, true)
    key, desc = '', ''
    CreateThread(function()
        while isOpen do
            Wait(0)
            RageUI.IsVisible(menu.main, function()
                RageUI.Button("Retour à l'origine", nil, {}, true, {
                    onSelected = function()
                        set(false)
                    end  
                })
                for k in pairs(cfg.Ped)do
                    RageUI.Button(cfg.Cat[k] or k, nil, {}, true, {
                        onSelected = function()
                            key = k
                        end
                    }, menu[k])
                end
            end)
            RageUI.IsVisible(menu[key], function ()
                for _,v in ipairs(cfg.Ped[key]) do
                    desc = ("- Hash : %s\n- Name : %s"):format(v.hash, v.name)
                    RageUI.Button(v.label, desc, {}, true, {
                        onSelected = function()
                            set(v.hash, key)
                        end
                    })
                end
            end)
        end
        menu.main = RMenu.DeleteType(menu.main, true)
        menu = {}
    end)
end

RegisterCommand('pedmenu', function()
    if not isOpen then
        ESX.TriggerServerCallback('supv_pedmenu:canOpen', function(can)
            if can then
                isOpen = true
                OpenPedMenu()
            end
        end)
    else
        RageUI.CloseAll()
        isOpen = false
    end
end, false)