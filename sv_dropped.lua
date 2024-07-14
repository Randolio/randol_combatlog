local Server = lib.load('sv_config')
local cachedCids = {}

local function getPlayersNearby(coords)
    local players = GetPlayers()
    local list = {}

    for i = 1, #players do
        local ply = tonumber(players[i])
        local ped = GetPlayerPed(ply)
        local pos = GetEntityCoords(ped)
        local dist = #(coords - pos)

        if dist <= 100.0 then
            list[#list+1] = ply
        end
    end

    return list
end

function OnPlayerLoaded(source)
    local src = source
    local player = GetPlayer(src)
    if not player then return end
    cachedCids[src] = { cid = GetPlyIdentifier(player), name = GetCharacterName(player), license = GetPlyLicense(player)}
end

function OnPlayerUnload(source)
    local src = source
    if cachedCids[src] then cachedCids[src] = nil end
end

AddEventHandler('playerDropped', function(reason)
    local src = source
    if not cachedCids[src] then return end

    local coords = GetEntityCoords(GetPlayerPed(src))
    local heading = GetEntityHeading(GetPlayerPed(src))
    local skin, model = GetPlayerSkinData(cachedCids[src].cid)
    if not skin then return end

    if reason then
        local reason_lower = string.lower(reason)
        for key, value in pairs(Server.ReasonList) do
            if string.find(reason_lower, key) then
                reason = value
                break
            end
        end
    end

    local data = {
        id = src,
        cid = cachedCids[src].cid,
        license = cachedCids[src].license,
        name = cachedCids[src].name,
        reason = reason or 'Unknown Reason',
        coords = vec4(coords.x, coords.y, coords.z-1.0, heading),
        model = model,
        skin = skin,
    }

    local plys = getPlayersNearby(coords)
    if #plys > 0 then
        for i = 1, #plys do
            TriggerClientEvent('randol_combatlog:client:onDropped', plys[i], data)
        end
    end
    cachedCids[src] = nil
end)

AddEventHandler('txAdmin:events:serverShuttingDown', function()
    table.wipe(cachedCids)
end)
