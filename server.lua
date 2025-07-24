local RSGCore = exports['rsg-core']:GetCoreObject()
lib.locale()

RSGCore.Functions.CreateUseableItem('matches', function(source, item)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)

    if not Player then
        print(locale('print_sv_started')..": " .. src .. "^7")
        return
    end

    local hasItem = Player.Functions.GetItemByName('matches')
    if not hasItem or hasItem.amount < 1 then
        TriggerClientEvent('ox_lib:notify', src, {
            title = locale('not_sv_1'),
            description = locale('not_sv_2'),
            type = 'error',
            duration = 3000
        })
        return
    end

    print(locale('print_sv_ply').." " .. Player.PlayerData.charinfo.firstname .. " "..locale('print_sv_ply2'))
    TriggerClientEvent('fire:startFire', src)
end)

RSGCore.Functions.CreateUseableItem('water', function(source, item)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)

    if not Player then
        print(locale('print_sv_started')..": " .. src .. "^7")
        return
    end

    local hasItem = Player.Functions.GetItemByName('water')
    if not hasItem or hasItem.amount < 1 then
        TriggerClientEvent('ox_lib:notify', src, {
            title = locale('not_sv_1'),
            description = locale('not_sv_3'),
            type = 'error',
            duration = 3000
        })
        return
    end

    TriggerClientEvent('fire:extinguishFire', src)
end)

RegisterNetEvent('fire:removeItem', function(item, amount)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)

    if not Player then
        print(locale('print_sv_started')..": " .. src .. "^7")
        return
    end

    local hasItem = Player.Functions.GetItemByName(item)
    if not hasItem or hasItem.amount < amount then

        return
    end

    Player.Functions.RemoveItem(item, amount)
    TriggerClientEvent('rsg-inventory:client:ItemBox', src, RSGCore.Shared.Items[item], 'remove', amount)

end)