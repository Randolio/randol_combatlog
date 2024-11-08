local temp = {}
local oxtarget = GetResourceState('ox_target') == 'started'
local npcTime = 15000 -- For changing how long the ghost person appears (in ms)

local function targetLocalEntity(entity, options, distance)
    if oxtarget then
        for _, option in ipairs(options) do
            option.distance = distance
            option.onSelect = option.action
            option.action = nil
        end
        exports.ox_target:addLocalEntity(entity, options)
    else
        exports['qb-target']:AddTargetEntity(entity, {
            options = options,
            distance = distance
        })
    end
end

function clearEverything()
    if next(temp) then
        for cid, data in pairs(temp) do
            if DoesEntityExist(data.entity) then
                if oxtarget then
                    exports.ox_target:removeLocalEntity(data.entity, 'View Information')
                else
                    exports['qb-target']:RemoveTargetEntity(data.entity, 'View Information')
                end
                DeleteEntity(data.entity)
            end
            if DoesEntityExist(data.prop) then
                DeleteEntity(data.prop)
            end
        end
        table.wipe(temp)
    end
end

local function attachBoard(ped)
    lib.requestModel(`prop_police_id_board`)
    local coords = GetEntityCoords(ped)
    local object = CreateObject(`prop_police_id_board`, coords.x, coords.y, coords.z, false, false, false)
    AttachEntityToEntity(object, ped, GetPedBoneIndex(ped, 58868), 0.12, 0.24, 0.0, 5.0, 0.0, 70.0, true, true, false, true, 1, true)
    SetModelAsNoLongerNeeded(`prop_police_id_board`)
    return object
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
    
    temp[data.cid].prop = attachBoard(temp[data.cid].entity)
    SetEntityAlpha(temp[data.cid].prop, 180)
    exports['illenium-appearance']:setPedAppearance(temp[data.cid].entity, data.skin)

    targetLocalEntity(temp[data.cid].entity, {
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
    }, 1.2)

    SetTimeout(npcTime, function()
        if DoesEntityExist(temp[data.cid].entity) then
            if oxtarget then
                exports.ox_target:removeLocalEntity(temp[data.cid].entity, 'View Information')
            else
                exports['qb-target']:RemoveTargetEntity(temp[data.cid].entity, 'View Information')
            end
            DeleteEntity(temp[data.cid].entity)
        end
        if DoesEntityExist(temp[data.cid].prop) then
            DeleteEntity(temp[data.cid].prop)
        end
        temp[data.cid] = nil
    end)
end)

AddEventHandler('onResourceStop', function(res)
    if GetCurrentResourceName() ~= res or not hasPlyLoaded() then return end
    clearEverything()
end)
