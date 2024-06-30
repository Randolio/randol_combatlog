if GetResourceState('es_extended') ~= 'started' then return end

local ESX = exports['es_extended']:getSharedObject()

function GetPlayer(id)
    return ESX.GetPlayerFromId(id)
end

function DoNotification(src, text, nType)
    TriggerClientEvent('esx:showNotification', src, text, nType)
end

function GetCharacterName(xPlayer)
    return xPlayer.getName()
end

function GetPlyIdentifier(xPlayer)
    return xPlayer.identifier
end

function GetPlyLicense(xPlayer)
    return xPlayer.license
end

function GetPlayerSkinData(cid)
    local result = MySQL.single.await('SELECT skin FROM users WHERE identifier = ?', {cid})
    if result and result.skin then
        local skinData = json.decode(result.skin)
        if skinData then
            return skinData, skinData.model
        end
    end
    return false
end

AddEventHandler('esx:playerLogout', function(playerId)
    OnPlayerUnload(playerId)
end)

AddEventHandler('esx:playerLoaded', function(source)
    OnPlayerLoaded(source)
end)