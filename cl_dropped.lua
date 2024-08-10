local temp = {}
local renderId = {}

function clearEverything()
    if next(temp) then
        for cid, data in pairs(temp) do
            if DoesEntityExist(data.entity) then
                exports['qb-target']:RemoveTargetEntity(data.entity, 'View Information')
                DeleteEntity(data.entity)
            end
            if DoesEntityExist(data.prop) then
                DeleteEntity(data.prop)
            end
            if DoesEntityExist(data.overlay) then
                DeleteEntity(data.overlay)
            end
        end
        table.wipe(temp)
        table.wipe(renderId)
    end
end

local function callScaleformMethod(scaleform, method, ...)
    local t
    local args = { ... }
    BeginScaleformMovieMethod(scaleform, method)
    for k, v in ipairs(args) do
        t = type(v)
        if t == 'string' then
            PushScaleformMovieMethodParameterString(v)
        elseif t == 'number' then
            if string.match(tostring(v), "%.") then
                PushScaleformMovieFunctionParameterFloat(v)
            else
                PushScaleformMovieFunctionParameterInt(v)
            end
        elseif t == 'boolean' then
            PushScaleformMovieMethodParameterBool(v)
        end
    end
    EndScaleformMovieMethod()
end

local function boardScaleform(data)
    local handle = lib.requestScaleformMovie('mugshot_board_01')
    local renderTargetName = ('ID_Text_%s'):format(data.cid)
    local propName = ('prop_police_id_text_%s'):format(data.cid)

    if not IsNamedRendertargetRegistered(renderTargetName) then
        RegisterNamedRendertarget(renderTargetName, 0)
    end
    if not IsNamedRendertargetLinked(propName) then
        LinkNamedRendertarget(propName)
    end
    if IsNamedRendertargetRegistered(renderTargetName) then
        renderId[data.cid] = GetNamedRendertargetRenderId(renderTargetName)
    end

    CreateThread(function()
        while renderId[data.cid] do
            if #(GetEntityCoords(cache.ped) - vec3(data.coords.x, data.coords.y, data.coords.z)) < 10.0 then
                SetTextRenderId(renderId[data.cid])
                Set_2dLayer(4)
                SetScriptGfxDrawBehindPausemenu(1)
                DrawScaleformMovie(handle, 0.405, 0.37, 0.81, 0.74, 255, 255, 255, 255, 0)
                SetScriptGfxDrawBehindPausemenu(0)
                SetTextRenderId(GetDefaultScriptRendertargetRenderId())
                SetScriptGfxDrawBehindPausemenu(1)
                SetScriptGfxDrawBehindPausemenu(0)
            end
            Wait(0)
        end
    end)
    callScaleformMethod(handle, 'SET_BOARD', 'INSERT SERVER NAME', data.name, 'Fuck all my opps.', ('Reason: %s'):format(data.reason), 0, data.id, 116)
end

local function attachBoard(ped)
    lib.requestModel(`prop_police_id_board`)
    lib.requestModel(`prop_police_id_text`)

    local coords = GetEntityCoords(ped)
    local object = CreateObject(`prop_police_id_board`, coords.x, coords.y, coords.z, false, false, false)
    local overlay = CreateObject(`prop_police_id_text`, coords.x, coords.y, coords.z, false, false, false)

    AttachEntityToEntity(object, ped, GetPedBoneIndex(ped, 58868), 0.12, 0.24, 0.0, 5.0, 0.0, 70.0, true, true, false, true, 1, true)
    AttachEntityToEntity(overlay, object, -1, 4103, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
    
    SetModelAsNoLongerNeeded(`prop_police_id_board`)
    SetModelAsNoLongerNeeded(`prop_police_id_text`)
    return object, overlay
end

RegisterNetEvent('randol_combatlog:client:onDropped', function(data)
    if GetInvokingResource() or not data then return end

    lib.requestModel(data.model)
    if not temp[data.cid] then temp[data.cid] = {} end
    temp[data.cid].entity = CreatePed(0, data.model, data.coords, false, false)
    
    SetEntityAsMissionEntity(temp[data.cid].entity)
    SetPedFleeAttributes(temp[data.cid].entity, 0, 0)
    SetBlockingOfNonTemporaryEvents(temp[data.cid].entity, true)
    SetEntityInvincible(temp[data.cid].entity, true)
    FreezeEntityPosition(temp[data.cid].entity, true)
    SetEntityAlpha(temp[data.cid].entity, 180)
    SetModelAsNoLongerNeeded(data.model)

    lib.requestAnimDict('mp_character_creation@customise@male_a')
    TaskPlayAnim(temp[data.cid].entity, 'mp_character_creation@customise@male_a', 'loop', 5.0, 5.0, -1, 01, 0, 0, 0, 0)
    RemoveAnimDict('mp_character_creation@customise@male_a')
    
    temp[data.cid].prop, temp[data.cid].overlay = attachBoard(temp[data.cid].entity)
    boardScaleform(data)
    exports['illenium-appearance']:setPedAppearance(temp[data.cid].entity, data.skin)

    exports['qb-target']:AddTargetEntity(temp[data.cid].entity, {
        options = {
            {
                icon = 'fa-solid fa-circle-info',
                label = 'View Information',
                action = function()
                    local menu = {
                        {
                            title = ('%s [%s]'):format(data.name, data.id),
                            description = ('Reason: %s'):format(data.reason),
                            icon = 'circle-info',
                            onSelect = function()
                                local info = ('**Character Name**: %s\n**ID**: %s\n**License**: %s\n**Reason**: %s'):format(data.name, data.id, data.license, data.reason)
                                lib.setClipboard(info)
                                lib.notify({ title = 'Player Information', description = 'Copied the player\'s information.', position = 'center-right'})
                            end,
                        }, 
                    }
                    lib.registerContext({ id = 'cl_ped'..data.cid, title = 'Player Disconnected', options = menu, })
                    lib.showContext('cl_ped'..data.cid)
                end,
            },
        },
        distance = 1.2,
    })

    SetTimeout(15000, function()
        if DoesEntityExist(temp[data.cid].entity) then
            exports['qb-target']:RemoveTargetEntity(temp[data.cid].entity, 'View Information')
            DeleteEntity(temp[data.cid].entity)
        end
        if DoesEntityExist(temp[data.cid].prop) then
            DeleteEntity(temp[data.cid].prop)
        end
        if DoesEntityExist(temp[data.cid].overlay) then
            DeleteEntity(temp[data.cid].overlay)
        end
        temp[data.cid] = nil
        renderId[data.cid] = nil
    end)
end)

AddEventHandler('onResourceStop', function(res)
    if GetCurrentResourceName() ~= res or not hasPlyLoaded() then return end
    clearEverything()
end)
