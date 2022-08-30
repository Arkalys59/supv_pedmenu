ESX.RegisterServerCallback('supv_pedmenu:canOpen', function(source, cb)
    local player = ESX.GetPlayerFromId(source)
    if Config.Access.admin[player.group] or Config.Access.identifier[player.identifier] then
        cb(true)
    end
    return
end)