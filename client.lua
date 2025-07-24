local activeFires = {}
local fireId = 0


local function CreateFire(coords)
    fireId = fireId + 1
    local currentFireId = fireId
    
   
    local foundGround, groundZ = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z + 1.0, false)
    local fireCoords = foundGround and vector3(coords.x, coords.y, groundZ + 0.2) or vector3(coords.x, coords.y, coords.z + 0.5)
    
   
    
    
    local fireHandle = StartScriptFire(fireCoords.x, fireCoords.y, fireCoords.z, Config.MaxFireIntensity or 2, false)
    local isVfx = false
    
    if not fireHandle or fireHandle == 0 then
       
        
        RequestNamedPtfxAsset('scr_michael2')
        local timeout = 0
        while not HasNamedPtfxAssetLoaded('scr_michael2') and timeout < 5000 do
            Wait(100)
            timeout = timeout + 100
        end
        if HasNamedPtfxAssetLoaded('scr_michael2') then
            fireHandle = StartParticleFxLoopedAtCoord('scr_mich2_fire', fireCoords.x, fireCoords.y, fireCoords.z, 0.0, 0.0, 0.0, 1.0, false, false, false)
            isVfx = true
            
        else
            
            return nil
        end
    end
    
    activeFires[currentFireId] = {
        coords = fireCoords,
        fireHandle = fireHandle,
        isVfx = isVfx,
        startTime = GetGameTimer()
    }
    
    
    
    SetTimeout(Config.FireDuration, function()
        if activeFires[currentFireId] then
            if activeFires[currentFireId].isVfx then
                StopParticleFxLooped(activeFires[currentFireId].fireHandle, false)
            else
                RemoveScriptFire(activeFires[currentFireId].fireHandle)
            end
            activeFires[currentFireId] = nil
            
        end
    end)
    
    return currentFireId
end

-- Find nearest fire
local function GetNearestFire(coords)
    local nearestFire = nil
    local nearestDistance = Config.ExtinguishDistance
    
    for id, fireData in pairs(activeFires) do
        local distance = #(coords - fireData.coords)
        if distance < nearestDistance then
            nearestDistance = distance
            nearestFire = { id = id, data = fireData, distance = distance }
        end
    end
    
    if not nearestFire then
       
    else
        
    end
    
    return nearestFire
end

local function ExtinguishFire(fireId)
    if activeFires[fireId] then
        local fireData = activeFires[fireId]
        if fireData.fireHandle and fireData.fireHandle ~= 0 then
            if fireData.isVfx then
                StopParticleFxLooped(fireData.fireHandle, false)
            else
                RemoveScriptFire(fireData.fireHandle)
            end
            activeFires[fireId] = nil
          
            return true
        else
            
            activeFires[fireId] = nil 
            return false
        end
    end
   
    return false
end


local function ExtinguishFiresInRadius(coords, radius)
    local extinguishedCount = 0
   

    
    for id, fireData in pairs(activeFires) do
        local distance = #(coords - fireData.coords)
        if distance <= radius then
            if ExtinguishFire(id) then
                extinguishedCount = extinguishedCount + 1
            end
        end
    end

   
    local gridSize = 1.5 
    local steps = math.ceil(radius * 2 / gridSize)
    local suppressedFires = 0
    
    for x = -steps, steps do
        for y = -steps, steps do
            local offsetX = x * gridSize
            local offsetY = y * gridSize
            local dist = math.sqrt(offsetX * offsetX + offsetY * offsetY)
            
            if dist <= radius then
                local checkCoords = vector3(coords.x + offsetX, coords.y + offsetY, coords.z)
                
                
                for zOffset = -2.0, 3.0, 1.0 do
                    local result = RemoveScriptFireAtCoord(checkCoords.x, checkCoords.y, checkCoords.z + zOffset)
                    if result then
                        suppressedFires = suppressedFires + 1
                    end
                end
            end
        end
    end

    
    
    for i = 1, 3 do
        local angle = (i - 1) * (360 / 3) 
        local radianAngle = math.rad(angle)
        local explosionRadius = radius * 0.3 
        
        local explodeX = coords.x + math.cos(radianAngle) * explosionRadius
        local explodeY = coords.y + math.sin(radianAngle) * explosionRadius
        local explodeZ = coords.z
        
       
        AddExplosion(explodeX, explodeY, explodeZ, 13, 0.1, false, true, 0.0)
        Wait(100) 
    end

    
    RequestNamedPtfxAsset('core')
    if HasNamedPtfxAssetLoaded('core') then
        for i = 1, 8 do
            local angle = (i - 1) * (360 / 8)
            local radianAngle = math.rad(angle)
            local particleRadius = radius * 0.5
            
            local particleX = coords.x + math.cos(radianAngle) * particleRadius
            local particleY = coords.y + math.sin(radianAngle) * particleRadius
            local particleZ = coords.z + 1.0
            
            StartParticleFxNonLoopedAtCoord('water_splash_ped_out', particleX, particleY, particleZ, 0.0, 0.0, 0.0, 2.0, false, false, false)
        end
    end

    local totalProcessed = extinguishedCount + suppressedFires
    

    return math.max(totalProcessed, 1) 
end


function RemoveScriptFireAtCoord(x, y, z)
    local wasRemoved = false
    
   
    for i = 1, 3 do
        local tempFire = StartScriptFire(x, y, z + (i * 0.1), 0.05, false)
        if tempFire and tempFire ~= 0 then
            Wait(50) 
            RemoveScriptFire(tempFire)
            wasRemoved = true
        end
    end
    
   
    local tempFire = StartScriptFire(x, y, z, 0.1, false)
    if tempFire and tempFire ~= 0 then
        RemoveScriptFire(tempFire)
        wasRemoved = true
    end
    
   
    local offsets = {
        {0.0, 0.0, 0.0},
        {0.5, 0.0, 0.0},
        {-0.5, 0.0, 0.0},
        {0.0, 0.5, 0.0},
        {0.0, -0.5, 0.0},
        {0.0, 0.0, 0.5},
        {0.0, 0.0, -0.5}
    }
    
    for _, offset in ipairs(offsets) do
        local checkX = x + offset[1]
        local checkY = y + offset[2]  
        local checkZ = z + offset[3]
        
        
        local testFire = StartScriptFire(checkX, checkY, checkZ, 0.01, false)
        if testFire and testFire ~= 0 then
            RemoveScriptFire(testFire)
            wasRemoved = true
        end
    end
    
    return wasRemoved
end

local function GetPlayerFireCount()
    local count = 0
    for _ in pairs(activeFires) do
        count = count + 1
    end
   
    return count
end


RegisterNetEvent('fire:startFire', function()
    print("^2[FireSystem] Received fire:startFire event^7")
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    
    if GetPlayerFireCount() >= Config.MaxFires then
        TriggerEvent('ox_lib:notify', {
            title = 'Fire System',
            description = 'Too many active fires!',
            type = 'error',
            duration = 3000
        })
        return
    end
    
    
    local heading = GetEntityHeading(playerPed)
    local forwardX = math.sin(math.rad(-heading))
    local forwardY = math.cos(math.rad(-heading))
    local fireCoords = vector3(coords.x + forwardX * Config.FirePlaceDistance, coords.y + forwardY * Config.FirePlaceDistance, coords.z)
    
   
    if Config.UseAnimations then
        TaskStartScenarioInPlace(playerPed, GetHashKey("WORLD_HUMAN_CROUCH_INSPECT"), -1, true, "StartScenario", 0, false)
        Wait(Config.LightFireTime)
        ClearPedTasks(playerPed)
    end
    
    local createdFireId = CreateFire(fireCoords)
    
    if createdFireId then
        TriggerEvent('ox_lib:notify', {
            title = 'Fire System',
            description = 'Fire started successfully!',
            type = 'success',
            duration = 3000
        })
        if Config.ConsumeMatches then
            TriggerServerEvent('fire:removeItem', 'matches', 1)
        end
    else
        TriggerEvent('ox_lib:notify', {
            title = 'Fire System',
            description = 'Failed to start fire!',
            type = 'error',
            duration = 3000
        })
    end
end)


RegisterNetEvent('fire:extinguishFire', function()
    
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    
   
    if Config.UseAnimations then
        TaskStartScenarioInPlace(playerPed, GetHashKey("WORLD_HUMAN_CROUCH_INSPECT"), -1, true, "StartScenario", 0, false)
        Wait(Config.ExtinguishTime)
        ClearPedTasks(playerPed)
    end
    
   
    local extinguishRadius = Config.ExtinguishDistance * 0.5 
    local extinguishedCount = ExtinguishFiresInRadius(coords, extinguishRadius)
    
    
    TriggerEvent('ox_lib:notify', {
        title = 'Fire System',
        description = 'Fire suppression completed! Area cleared.',
        type = 'success',
        duration = 3000
    })
    
    if Config.ConsumeWater then
        TriggerServerEvent('fire:removeItem', 'water', 1)
    end
end)


AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        for id, fireData in pairs(activeFires) do
            if fireData.isVfx then
                StopParticleFxLooped(fireData.fireHandle, false)
            else
                RemoveScriptFire(fireData.fireHandle)
            end
        end
        activeFires = {}
       
    end
end)

