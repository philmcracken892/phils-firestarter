local RSGCore = exports['rsg-core']:GetCoreObject()


RSGCore.Functions.CreateUseableItem('matches', function(source, item)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    
    if not Player then
        print("^1[FireSystem] Player not found for source: " .. src .. "^7")
        return
    end
    
    local hasItem = Player.Functions.GetItemByName('matches')
    if not hasItem or hasItem.amount < 1 then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Fire System',
            description = 'You need matches to start a fire!',
            type = 'error',
            duration = 3000
        })
        return
    end
    
    print("^2[FireSystem] Player " .. Player.PlayerData.charinfo.firstname .. " used matches^7")
    TriggerClientEvent('fire:startFire', src)
end)


RSGCore.Functions.CreateUseableItem('water', function(source, item)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    
    if not Player then
        print("^1[FireSystem] Player not found for source: " .. src .. "^7")
        return
    end
    
    local hasItem = Player.Functions.GetItemByName('water')
    if not hasItem or hasItem.amount < 1 then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Fire System',
            description = 'You need a water bucket to extinguish a fire!',
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
        print("^1[FireSystem] Player not found for source: " .. src .. "^7")
        return
    end
    
    local hasItem = Player.Functions.GetItemByName(item)
    if not hasItem or hasItem.amount < amount then
       
        return
    end
    
    Player.Functions.RemoveItem(item, amount)
    TriggerClientEvent('inventory:client:ItemBox', src, RSGCore.Shared.Items[item], 'remove', amount)
   
end)